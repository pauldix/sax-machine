#include <search.h>
#include <string.h>
#include <stdio.h>
#include <ruby.h>
#include <stdlib.h>

#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>
#include <libxml/xmlreader.h>
#include <libxml/HTMLparser.h>
#include <libxml/HTMLtree.h>

#define SAX_HASH_SIZE 200
#define MAX_TAGS 20
#define false 0
#define true 1

typedef struct {
	const char *setter;
	const char *value;
	const char **attrs;
} SAXMachineElement;

typedef struct {
	const char *name;
	int numberOfElements;
	SAXMachineElement *elements[MAX_TAGS];
} SAXMachineTag;

typedef struct saxMachineHandler SAXMachineHandler;
struct saxMachineHandler {
	// short parseCurrentTag;
	SAXMachineElement *currentElement;
	SAXMachineTag *tags[SAX_HASH_SIZE];
	SAXMachineHandler *childHandlers[SAX_HASH_SIZE];
};

SAXMachineHandler *saxHandlersForClasses[SAX_HASH_SIZE];
SAXMachineHandler *handlerStack[20];
SAXMachineHandler *currentHandler;
int handlerStackTop;

const char * saxMachineTag;

// hash algorithm from R. Sedgwick, Algorithms in C++
static inline int hash_index(const char * key) {
	int h = 0, a = 127, temp;
	
	for (; *key != 0; key++) {
		temp = (a * h + *key);
		if (temp < 0) temp = -temp;
		h = temp % SAX_HASH_SIZE;
	}
	
	return h;
}

static SAXMachineHandler *new_handler() {
	SAXMachineHandler *handler = (SAXMachineHandler *) malloc(sizeof(SAXMachineHandler));
	handler->currentElement = NULL;
	int i;
	for (i = 0; i < SAX_HASH_SIZE; i++) {
		handler->tags[i] = NULL;
		handler->childHandlers[i] = NULL;
	}
	return handler;
}

static SAXMachineElement * new_element() {
	SAXMachineElement * element = (SAXMachineElement *) malloc(sizeof(SAXMachineElement));
	element->setter = NULL;
	element->value = NULL;
	element->attrs = NULL;
	return element;	
}

static SAXMachineTag * new_tag(const char * name) {
	SAXMachineTag * tag = (SAXMachineTag *) malloc(sizeof(SAXMachineTag));
	int i;
	for (i = 0; i < MAX_TAGS; i++) {
		tag->elements[i] = NULL;
	}
	tag->numberOfElements = 0;
	tag->name = name;
	return tag;
}

static inline SAXMachineHandler * handler_for_class(const char *name) {
	return saxHandlersForClasses[hash_index(name)];
}

static const char ** convert_ruby_attrs_to_xml_attrs(VALUE attrs) {
	int length = RARRAY(attrs)->len;
	if (length == 0) {
		return NULL;
	}

	const char **xmlAttrs = (const char **) malloc(length * sizeof(char *));
	int i;
	for (i = 0; i < length; i++) {
		VALUE a = rb_ary_entry(attrs, i);
		xmlAttrs[i] = StringValuePtr(a);
	}
	return xmlAttrs;
}

static VALUE add_element(VALUE self, VALUE name, VALUE setter, VALUE attribute_holding_value, VALUE attrs) {
	// first create the sax handler for this class if it doesn't exist
	VALUE klass = rb_funcall(self, rb_intern("parser_class"), 0);
	const char *className = StringValuePtr(klass);
	int handlerIndex = hash_index(className);
	if (saxHandlersForClasses[handlerIndex] == NULL) {
		saxHandlersForClasses[handlerIndex] = new_handler();
	}
	SAXMachineHandler *handler = saxHandlersForClasses[handlerIndex];
	
	// now create the tag if it's not there yet
	const char *tag_name = StringValuePtr(name);
	int tag_index = hash_index(tag_name);
	if (handler->tags[tag_index] == NULL) {
		handler->tags[tag_index] = new_tag(tag_name);
	}
	
	SAXMachineTag *tag = handler->tags[tag_index];
	
	// now create the element and add it to the tag
	SAXMachineElement * element = new_element();
	element->setter = StringValuePtr(setter);
	element->attrs  = convert_ruby_attrs_to_xml_attrs(attrs);
	// if (attribute_holding_value != Qnil) {
	// 	element->value = StringValuePtr(attribute_holding_value);
	// }
	tag->elements[tag->numberOfElements++] = element;
	return name;
}

static inline SAXMachineHandler * currentHandlerParent() {
	if (handlerStackTop <= 0) {
		return NULL;
	}
	else {
		return handlerStack[handlerStackTop - 1];
	}
}

static inline short attributes_match_for_element(SAXMachineElement *element, const xmlChar **atts) {
	if (atts == NULL) {
		return element->attrs == NULL;
	}
	const char **subsetAtts = element->attrs;
	const char * attName;
	const char * attValue;
	int i = 0;
	
	while((attName = subsetAtts[i]) != NULL) {
		attValue = subsetAtts[++i];
		short match = false;
		int j = 0;
		const xmlChar * xmlAttName;
		while ((xmlAttName = atts[j]) != NULL) {
			const xmlChar * xmlAttValue = atts[++j];
			if (strcmp(attName, (const char *)xmlAttName) == 0 && strcmp(attValue, (const char *)xmlAttValue) == 0) {
				match = true;
				break;
			}
			j++;
		}
		if (match == false) {
			return false;
		}
		i++;
	}
	return true;
}

static inline SAXMachineElement * element_for_tag_in_handler(SAXMachineHandler *handler, const xmlChar *name, const xmlChar **atts) {
	int tag_index = hash_index((const char *)name);
	if (handler->tags[tag_index] != NULL && strcmp(handler->tags[tag_index]->name, (const char *)name) == 0) {
		SAXMachineTag * tag = handler->tags[tag_index];
		SAXMachineElement * noAttributeElement = NULL;
		SAXMachineElement * element = NULL;
		int i = 0;
		do {
			if (tag->elements[i]->attrs == NULL) {
				noAttributeElement = tag->elements[i];
				if (atts == NULL) { break; }
			}
			else { // this is a possible attributes match
				if (attributes_match_for_element(tag->elements[i], atts)) {
					element = tag->elements[i];
					break;
				}
			}
			i++;
		} while (tag->elements[i] != NULL);
		return element == NULL ? noAttributeElement : element;
	}
	else {
		return NULL;
	}
}

static inline short tag_matches_child_handler_in_handler(SAXMachineHandler *handler, const xmlChar *name) {
	return handler->childHandlers[hash_index((const char *)name)] != NULL;
}

/*
 * call-seq:
 *  parse_memory(data)
 *
 * Parse the document stored in +data+
 */
static VALUE parse_memory(VALUE self, VALUE data)
{
  xmlSAXHandlerPtr handler;
  Data_Get_Struct(self, xmlSAXHandler, handler);
  xmlSAXUserParseMemory(  handler,
                          (void *)self,
                          StringValuePtr(data),
                          NUM2INT(rb_funcall(data, rb_intern("length"), 0))
  );
  return data;
}

static void start_document(void * ctx)
{
  VALUE self = (VALUE)ctx;
	VALUE klass = rb_funcall(rb_funcall(self, rb_intern("parser_class"), 0), rb_intern("to_s"), 0);
	const char * className = StringValuePtr(klass);
	handlerStackTop = 0;
	handlerStack[handlerStackTop] = handler_for_class(className);
	currentHandler = handlerStack[handlerStackTop];
//  rb_funcall(self, rb_intern("start_document"), 0);
}

static void end_document(void * ctx)
{
	handlerStack[0] = NULL;
//  VALUE self = (VALUE)ctx;
//  rb_funcall(self, rb_intern("end_document"), 0);
}

static void start_element(void * ctx, const xmlChar *name, const xmlChar **atts)
{
	SAXMachineElement * element = element_for_tag_in_handler(currentHandler, name, atts);
	if (element != NULL) {
	  VALUE self = (VALUE)ctx;
		if (element->value == NULL) {
			currentHandler->currentElement = element;
			rb_funcall(self, rb_intern("start_tag"), 1, rb_str_new2(element->setter));
		  // VALUE attributes = rb_ary_new();
		  // const xmlChar * attr;
		  // int i = 0;
		  // if(atts) {
		  //   while((attr = atts[i]) != NULL) {
		  //     rb_funcall(attributes, rb_intern("<<"), 1, rb_str_new2((const char *)attr));
		  //     i++;
		  //   }
		  // }
		  // 
		  // rb_funcall( self,
		  //             rb_intern("start_element"),
		  //             2,
		  //             rb_str_new2((const char *)name),
		  //             attributes
		  // );
		}
		else {
			const xmlChar * att;
			int i = 0;
			while ((att = atts[i]) != NULL) {
				if (strcmp((const char *)att, element->value) == 0) {
					rb_funcall(self, rb_intern("set_value_from_attribute"), 2, rb_str_new2(element->setter), rb_str_new2(element->value));
					break;
				}
				i++;
			}
		}
	}
}

static void end_element(void * ctx, const xmlChar *name)
{
	if (currentHandler->currentElement != NULL) {
		
	  VALUE self = (VALUE)ctx;
	  rb_funcall(self, rb_intern("end_tag"), 0);
		
		currentHandler->currentElement = NULL;
		// pop the stack if this is the end of a collection
		SAXMachineHandler * parent = currentHandlerParent();
		if (parent != NULL) {
			if (tag_matches_child_handler_in_handler(parent, name)) {
				handlerStack[handlerStackTop--] = NULL;
			}
		}
	}
}

static void characters_func(void * ctx, const xmlChar * ch, int len)
{
	if (currentHandler->currentElement != NULL) {
	  VALUE self = (VALUE)ctx;
	  VALUE str = rb_str_new((const char *)ch, (long)len);
	  rb_funcall(self, rb_intern("characters"), 1, str);
	}
}

static void comment_func(void * ctx, const xmlChar * value)
{
	if (currentHandler->currentElement == NULL) {
	  VALUE self = (VALUE)ctx;
	  VALUE str = rb_str_new2((const char *)value);
	  rb_funcall(self, rb_intern("comment"), 1, str);
	}
}

#ifndef XP_WIN
static void warning_func(void * ctx, const char *msg, ...)
{
  VALUE self = (VALUE)ctx;
  char * message;

  va_list args;
  va_start(args, msg);
  vasprintf(&message, msg, args);
  va_end(args);

  rb_funcall(self, rb_intern("warning"), 1, rb_str_new2(message));
  free(message);
}
#endif

#ifndef XP_WIN
static void error_func(void * ctx, const char *msg, ...)
{
  VALUE self = (VALUE)ctx;
  char * message;

  va_list args;
  va_start(args, msg);
  vasprintf(&message, msg, args);
  va_end(args);

  rb_funcall(self, rb_intern("error"), 1, rb_str_new2(message));
  free(message);
}
#endif

static void cdata_block(void * ctx, const xmlChar * value, int len)
{
	if (currentHandler->currentElement == NULL) {
	  VALUE self = (VALUE)ctx;
	  VALUE string = rb_str_new((const char *)value, (long)len);
	  rb_funcall(self, rb_intern("cdata_block"), 1, string);
	}
}

static void deallocate(xmlSAXHandlerPtr handler)
{
  free(handler);
}

static VALUE allocate(VALUE klass)
{
  xmlSAXHandlerPtr handler = calloc(1, sizeof(xmlSAXHandler));

  handler->startDocument = start_document;
  handler->endDocument = end_document;
  handler->startElement = start_element;
  handler->endElement = end_element;
  handler->characters = characters_func;
  handler->comment = comment_func;
#ifndef XP_WIN
  /*
   * The va*functions aren't in ming, and I don't want to deal with
   * it right now.....
   *
   */
  handler->warning = warning_func;
  handler->error = error_func;
#endif
  handler->cdataBlock = cdata_block;

  return Data_Wrap_Struct(klass, NULL, deallocate, handler);
}

static VALUE add_tag(VALUE self, VALUE tagName) {
	saxMachineTag = StringValuePtr(tagName);
	return tagName;
}

static VALUE get_cl(VALUE self) {
	return rb_funcall(self, rb_intern("class"), 0);
}

VALUE cNokogiriXmlSaxParser ;
void Init_native()
{
	// we're storing the sax handler information for all the classes loaded. null it out to start
	int i;
	for (i = 0; i < SAX_HASH_SIZE; i++) {
		saxHandlersForClasses[i] = NULL;
	}
	
  VALUE mSAXMachine = rb_const_get(rb_cObject, rb_intern("SAXCMachine"));
  VALUE klass = cNokogiriXmlSaxParser =
    rb_const_get(mSAXMachine, rb_intern("SAXCParser"));
  rb_define_alloc_func(klass, allocate);
  rb_define_method(klass, "parse_memory", parse_memory, 1);
  rb_define_method(klass, "add_tag", add_tag, 1);
	rb_define_method(klass, "get_cl", get_cl, 0);
	rb_define_method(klass, "add_element", add_element, 4);
}
