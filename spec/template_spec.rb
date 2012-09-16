require 'rspec'
require 'fuzzbert'

describe FuzzBert::Template do

  describe "new" do
    it "takes a String parameter" do
      FuzzBert::Template.new("test").should be_an_instance_of(FuzzBert::Template)
    end
  end

  describe "set" do
    it "allows to define callbacks for template variables" do
      t = FuzzBert::Template.new "a${var}c"
      t.set(:var) { "b" }
      t.to_data.should == "abc"
    end

    it "takes only Symbols to reference the template variables" do
      t = FuzzBert::Template.new "a${var}c"
      t.set("var") { "b" }
      -> { t.to_data }.should raise_error
    end
  end

  describe "to_data" do
    it "can replace multiple template variables that possess a callback defined by set" do
      t = FuzzBert::Template.new "a${var1}c${var2}"
      t.set(:var1) { "b" }
      t.set(:var2) { "d" }
      t.to_data.should == "abcd"
    end

    specify "the dollar sign can be escaped with a backslash" do
      t = FuzzBert::Template.new "a\\${var}c"
      t.to_data.should == "a${var}c"
    end

    specify "a backslash can be escaped with another backslash" do
      t = FuzzBert::Template.new "a\\\\c"
      t.to_data.should == "a\\c"
    end

    it "raises an error if no closing brace is found for an open one" do
      -> { FuzzBert::Template.new "a${bc" }.should raise_error
    end

    it "does allow curly braces within a template variable identifier" do
      t = FuzzBert::Template.new "a${v{ar}c"
      t.set("v{ar".to_sym) { "b" }
      t.to_data.should == "abc"
    end

    it "does allow backslashes within a template variable identifier" do
      t = FuzzBert::Template.new "a${v\\ar}c"
      t.set("v\\ar".to_sym) { "b" }
      t.to_data.should == "abc"
    end

    it "allows text only" do
      t = FuzzBert::Template.new "abc"
      t.to_data.should == "abc"
    end

    it "allows variables only" do
      t = FuzzBert::Template.new "${a}${b}${c}"
      t.set(:a) { "a" }
      t.set(:b) { "b" }
      t.set(:c) { "c" }
      t.to_data.should == "abc"
    end

    it "allows heredoc strings" do
      t = FuzzBert::Template.new <<-EOS
{ user: { id: ${id}, name: "${name}" } }
      EOS

      t.set(:id) { "5" }
      t.set(:name) { "FuzzBert" }
      t.to_data.should == "{ user: { id: 5, name: \"FuzzBert\" } }\n"
    end
  end

end
