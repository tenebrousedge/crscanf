require "./spec_helper"

describe Scanf do
  it "scans chars" do
    scanf("%c").call("a").should eq({"a"})
  end

  it "scans strings" do
    scanf("%3s").call("abc").should eq({"abc"})
  end

  it "scans integers" do
    scanf("%d").call("123").should eq({123})
  end

  it "scans floats" do
    scanf("%f").call("0.0").should eq({0.0_f32})
  end
end
