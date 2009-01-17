#include <ruby.h>
#include <stdlib.h>

char * someTag;

static VALUE set_tag(VALUE self, VALUE t) {
	someTag = StringValuePtr(t);
	return t;
}

static VALUE get_tag() {
	return rb_str_new2(someTag);
}

VALUE cFoo;
void Init_foo4r() {
	cFoo = rb_const_get(rb_cObject, rb_intern("Foo"));
	rb_define_method(cFoo, "set_tag", set_tag, 1);
	rb_define_method(cFoo, "get_tag", get_tag, 0);
}