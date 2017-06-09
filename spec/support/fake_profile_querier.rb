# frozen_string_literal: true

class FakeProfileQuerier
  attr_reader :id

  def self.query(**params)
    new(**params).query
  end

  def initialize(id:)
    @id = id
  end

  def query
    return {} if id == 'badqueryid'
    return fg_attrs.merge(last_name: nil) if id == 'invalidid'
    fg_attrs.merge(username: id)
  end

  private

  def fg_attrs
    FactoryGirl.attributes_for(:student)
  end
end
