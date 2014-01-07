require 'test/unit'

class TestSymbol < Test::Unit::TestCase
  # [ruby-core:3573]

  def assert_eval_inspected(sym)
    n = sym.inspect
    assert_nothing_raised(SyntaxError) {assert_equal(sym, eval(n))}
  end

  def test_inspect_invalid
    # 2) Symbol#inspect sometimes returns invalid symbol representations:
    assert_eval_inspected(:"!".intern)
    assert_eval_inspected(:"=".intern)
    assert_eval_inspected(:"0".intern)
    assert_eval_inspected(:"$1".intern)
    assert_eval_inspected(:"@1".intern)
    assert_eval_inspected(:"@@1".intern)
    assert_eval_inspected(:"@".intern)
    assert_eval_inspected(:"@@".intern)
  end

  def assert_inspect_evaled(n)
    assert_nothing_raised(SyntaxError) {assert_equal(n, eval(n).inspect)}
  end

  def test_inspect_suboptimal
    # 3) Symbol#inspect sometimes returns suboptimal symbol representations:
    assert_inspect_evaled(':foo.intern')
    assert_inspect_evaled(':foo!.intern')
    assert_inspect_evaled(':bar?.intern')
    assert_inspect_evaled(':<<.intern')
    assert_inspect_evaled(':>>.intern')
    assert_inspect_evaled(':<=.intern')
    assert_inspect_evaled(':>=.intern')
    assert_inspect_evaled(':=~.intern')
    assert_inspect_evaled(':==.intern')
    assert_inspect_evaled(':===.intern')
    assert_raise(SyntaxError) {eval ':=.intern'}
    assert_inspect_evaled(':*.intern')
    assert_inspect_evaled(':**.intern')
    assert_raise(SyntaxError) {eval ':***.intern'}
    assert_inspect_evaled(':+.intern')
    assert_inspect_evaled(':-.intern')
    assert_inspect_evaled(':+@.intern')
    assert_inspect_evaled(':-@.intern')
    assert_inspect_evaled(':|.intern')
    assert_inspect_evaled(':^.intern')
    assert_inspect_evaled(':&.intern')
    assert_inspect_evaled(':/.intern')
    assert_inspect_evaled(':%.intern')
    assert_inspect_evaled(':~.intern')
    assert_inspect_evaled(':`.intern')
    assert_inspect_evaled(':[].intern')
    assert_inspect_evaled(':[]=.intern')
    assert_raise(SyntaxError) {eval ':||.intern'}
    assert_raise(SyntaxError) {eval ':&&.intern'}
    assert_raise(SyntaxError) {eval ':[.intern'}
  end

  def test_inspect_dollar
    # 4) :$- always treats next character literally:
    sym = "$-".intern
    assert_nothing_raised(SyntaxError) {assert_equal(sym, eval(':$-.intern'))}
    assert_nothing_raised(SyntaxError) {assert_equal(sym, eval("(:$-\n).intern"))}
    assert_nothing_raised(SyntaxError) {assert_equal(sym, eval(":$- .intern"))}
    assert_nothing_raised(SyntaxError) {assert_equal(sym, eval("(:$-#\n).intern"))} # I'm not sure I understand this test :o
    assert_raise(SyntaxError) {eval ':$-(.intern'}
  end

  def test_inspect_number
    # 5) Inconsistency between :$0 and :$1? The first one is valid, but the 
    # latter isn't.
    assert_inspect_evaled(':$0.intern')
    assert_inspect_evaled(':$1.intern')
  end

  def test_to_proc
    assert_equal %w(1 2 3), (1..3).map(&:to_s)
    [
      [],
      [1],
      [1, 2],
      [1, [2, 3]],
    ].each do |ary|
      ary_id = ary.object_id
      assert_equal ary_id, :object_id.to_proc.call(ary)
      ary_ids = ary.collect{|x| x.object_id }
      assert_equal ary_ids, ary.collect(&:object_id)
    end
  end
end
