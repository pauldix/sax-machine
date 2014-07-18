require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class A
  SAXMachine.configure(A) do |c|
    c.element :title
  end
end

class B < A
  SAXMachine.configure(B) do |c|
    c.element :b
  end
end

class C < B
  SAXMachine.configure(C) do |c|
    c.element :c
  end
end

describe "SAXMachine configure" do
  before do
    xml = "<top><title>Test</title><b>Matched!</b><c>And Again</c></top>"
    @a = A.new
    @a.parse xml
    @b = B.new
    @b.parse xml
    @c = C.new
    @c.parse xml
  end

  it { expect(@a).to be_a(A) }
  it { expect(@a).not_to be_a(B) }
  it { expect(@a).to be_a(SAXMachine) }
  it { expect(@a.title).to eq("Test") }
  it { expect(@b).to be_a(A) }
  it { expect(@b).to be_a(B) }
  it { expect(@b).to be_a(SAXMachine) }
  it { expect(@b.title).to eq("Test") }
  it { expect(@b.b).to eq("Matched!") }
  it { expect(@c).to be_a(A) }
  it { expect(@c).to be_a(B) }
  it { expect(@c).to be_a(C) }
  it { expect(@c).to be_a(SAXMachine) }
  it { expect(@c.title).to eq("Test") }
  it { expect(@c.b).to eq("Matched!") }
  it { expect(@c.c).to eq("And Again") }
end
