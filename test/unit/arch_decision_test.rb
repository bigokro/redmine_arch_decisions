require File.dirname(__FILE__) + '/../test_helper'

class ArchDecisionTest < ActiveSupport::TestCase
  fixtures :projects, 
            :factors, 
            :arch_decision_factors, 
            :arch_decisions, 
            :strategies, 
            :arch_decision_discussions,
            :arch_decision_statuses

  def setup
    @valid = arch_decisions(:valid)
  end

  def test_validity
    assert @valid.valid?
  end

  def test_summary_max_length
    valid_summary_max_length = arch_decisions(:valid_summary_max_length)
    assert valid_summary_max_length.valid?
  end

  def test_summary_max_length_plus_one
    valid_ad = arch_decisions(:valid_summary_max_length)
    invalid_ad = valid_ad.clone
    invalid_ad.summary += "a"
    assert !invalid_ad.save
    fields = [:summary]
    lengths = [ArchDecision::SUMMARY_MAX_SIZE]
    assert_fields_max_length_enforced(invalid_ad, fields, lengths)
  end
  
  def test_required_fields
    invalid_ad = @valid.clone
    invalid_ad.summary = nil
    invalid_ad.project = nil
    invalid_ad.status = nil
    invalid_ad.created_by = nil
    invalid_ad.updated_by = nil
    assert !invalid_ad.save
    fields = [:summary, :project, :status, :created_by, :updated_by]
    assert_required_fields_enforced(invalid_ad, fields)
  end
  
  def test_status_change
    new_status = arch_decision_statuses(:valid_name_max_length)
    assert_not_equal new_status, @valid.status
    @valid.status_id = new_status.id
    @valid.save
    assert_equal new_status.name, @valid.status.name
  end

  def test_destroy
    id = @valid.id
    ArchDecision.find(id).destroy
    assert_nil ArchDecision.find_by_id(id)
  end
  
  def test_destroy_factors_survive
    id = @valid.id
    fid = factors(:valid).id
    adfid = arch_decision_factors(:valid_valid).id
    ArchDecision.find(id).destroy
    assert_nil ArchDecisionFactor.find_by_id(adfid)
    assert_not_nil Factor.find_by_id(fid)
  end
  
  def test_destroy_strategies_die
    id = @valid.id
    sid = strategies(:valid).id
    ArchDecision.find(id).destroy
    assert_nil Strategy.find_by_id(sid)
  end
  
  def test_destroy_discussions_die
    id = @valid.id
    did = arch_decision_discussions(:arch_decision_discussion_1).id
    ArchDecision.find(id).destroy
    assert_nil ArchDecisionDiscussion.find_by_id(did)
  end
  
  def test_remove_factor_top_of_list
    test_remove_or_destroy_factor(1, false)
  end

  def test_remove_factor_second_on_list
    test_remove_or_destroy_factor(2, false)
  end

  def test_remove_factor_last_on_list
    test_remove_or_destroy_factor(4, false)
  end

  def test_remove_factor_not_on_list
    id = 1234567890
    begin
      @valid.remove_factor(id);
      assert false
    rescue
      assert_equal 4, @valid.factors.size
      (1..4).each do |i|
        ad_factor = @valid.arch_decision_factors[i-1]
        assert_equal i, ad_factor.priority
        assert ad_factor.factor.summary.include?(i.to_s)
      end
    end
  end

  def test_destroy_factor_top_of_list
    test_remove_or_destroy_factor(1, true)
  end

  def test_destroy_factor_second_on_list
    test_remove_or_destroy_factor(2, true)
  end

  def test_destroy_factor_last_on_list
    test_remove_or_destroy_factor(4, true)
  end

  def test_destroy_factor_not_on_list
    id = 1234567890
    begin
      @valid.destroy_factor(id);
      assert false
    rescue
      assert_equal 4, @valid.factors.size
      (1..4).each do |i|
        ad_factor = @valid.arch_decision_factors[i-1]
        assert_equal i, ad_factor.priority
        assert ad_factor.factor.summary.include?(i.to_s)
      end
    end
  end

  def test_prioritize_factor_two_to_one
    id1 = factors(:valid).id
    id2 = factors(:valid_2).id
    @valid.prioritize_factor(id2, id1)
    #TODO: move this to the method? Is this a bug to be fixed?
    @valid.reload
    assert_equal 4, @valid.factors.size
    (1..4).each do |i|
      ad_factor = @valid.arch_decision_factors[i-1]
      assert_equal i, ad_factor.priority
      factor_num = case i
        when 1 then "2"
        when 2 then "1"
        else i.to_s
      end
      assert ad_factor.factor.summary.include?(factor_num)
    end
  end

  def test_prioritize_factor_one_to_two
    id1 = factors(:valid).id
    id2 = factors(:valid_2).id
    @valid.prioritize_factor(id1, id2)
    #TODO: move this to the method? Is this a bug to be fixed?
    @valid.reload
    assert_equal 4, @valid.factors.size
    (1..4).each do |i|
      ad_factor = @valid.arch_decision_factors[i-1]
      assert_equal i, ad_factor.priority
      factor_num = i.to_s
      assert ad_factor.factor.summary.include?(factor_num)
    end
  end

  def test_prioritize_factor_three_to_two
    id3 = factors(:valid_3).id
    id2 = factors(:valid_2).id
    @valid.prioritize_factor(id3, id2)
    #TODO: move this to the method? Is this a bug to be fixed?
    @valid.reload
    assert_equal 4, @valid.factors.size
    (1..4).each do |i|
      ad_factor = @valid.arch_decision_factors[i-1]
      assert_equal i, ad_factor.priority
      factor_num = case i
        when 2 then "3"
        when 3 then "2"
        else i.to_s
      end
      assert ad_factor.factor.summary.include?(factor_num)
    end
  end

  def test_prioritize_factor_bottom_to_top
    id4 = factors(:valid_4).id
    @valid.prioritize_factor(id4)
    #TODO: move this to the method? Is this a bug to be fixed?
    @valid.reload
    assert_equal 4, @valid.factors.size
    (1..4).each do |i|
      ad_factor = @valid.arch_decision_factors[i-1]
      assert_equal i, ad_factor.priority
      factor_num = case i
        when 1 then "4"
        else (i-1).to_s
      end
      assert ad_factor.factor.summary.include?(factor_num)
    end
  end

  def test_prioritize_factor_top_to_bottom
    id1 = factors(:valid).id
    @valid.prioritize_factor(nil, id1)
    #TODO: move this to the method? Is this a bug to be fixed?
    @valid.reload
    assert_equal 4, @valid.factors.size
    (1..4).each do |i|
      ad_factor = @valid.arch_decision_factors[i-1]
      assert_equal i, ad_factor.priority
      factor_num = case i
        when 4 then "1"
        else (i+1).to_s
      end
      assert ad_factor.factor.summary.include?(factor_num)
    end
  end

  private
  
  def test_remove_or_destroy_factor(index, destroy)
    id = factors(index == 1 ? :valid : ("valid_" + index.to_s).to_sym).id
    destroy ? @valid.destroy_factor(id) : @valid.remove_factor(id)
    assert_equal 3, @valid.factors.size
    (1..3).each do |i|
      ad_factor = @valid.arch_decision_factors[i-1]
      assert_equal i, ad_factor.priority
      assert ad_factor.factor.summary.include?(((i < index ? i : i+1)).to_s)
    end
    destroy ? assert_nil(Factor.find_by_id(id)) : assert_not_nil(Factor.find(id))
  end

  def test_resolved
    ad = @valid.clone
    ad.status.is_resolved = true
    assert ad.resolved?
    ad.status.is_resolved = false
    assert !ad.resolved?
  end

end
