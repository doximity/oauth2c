# Copyright 2017 Doximity, Inc. <support@doximity.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "spec_helper"

RSpec.describe OAuth2c::Cache::Backends::InMemoryLRU do
  subject do
    described_class.new(5)
  end

  let :size do
    5
  end

  it "discard least recently used when going over size" do
    overflow = 3
    keys = (1..size+overflow)

    # Add each key to the store
    keys.each { |n| subject.store(n, n) }

    # Ensure that all keys higher the underflow exist and the
    # lowers got evicted.
    keys.each do |n|
      if n <= overflow
        expect(subject.lookup(n)).to be_nil
      else
        expect(subject.lookup(n)).to eq(n)
      end
    end
  end

  it "discard least recently used" do
    (1..size).each { |n| subject.store(n, n) }

    # LRU order after insert
    # [1, 2, 3, 4, 5]

    subject.lookup(4)
    subject.lookup(2)

    # LRU order after lookups
    # [1, 3, 5, 4, 2]

    subject.store(size+1, size+1)
    subject.store(size+2, size+2)

    expect(subject.lookup(1)).to be_nil
    expect(subject.lookup(3)).to be_nil

    expect(subject.lookup(2)).to eq(2)
    expect(subject.lookup(4)).to eq(4)
    expect(subject.lookup(5)).to eq(5)
    expect(subject.lookup(6)).to eq(6)
    expect(subject.lookup(7)).to eq(7)
  end
end
