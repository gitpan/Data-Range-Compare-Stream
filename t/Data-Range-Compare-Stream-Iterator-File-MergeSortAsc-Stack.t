use strict;
use warnings;
use Test::More qw(no_plan);

use_ok('Data::Range::Compare::Stream::Iterator::File::MergeSortAsc::Stack');


{
  my $o=new  Data::Range::Compare::Stream::Iterator::File::MergeSortAsc::Stack;

  ok($o,'object should exist');
  $o->push('test');
  cmp_ok($o->has_next,'==',1,'has_next check');
  $o->push('test');
  cmp_ok($o->has_next,'==',2,'has_next check');
  cmp_ok($o->get_next,'eq','test','get_next test');
  cmp_ok($o->has_next,'==',1,'has_next check');
  $o->push('test2');
  cmp_ok($o->has_next,'==',2,'has_next check');
  cmp_ok($o->get_next,'eq','test','get_next test');
  cmp_ok($o->has_next,'==',1,'has_next check');
  cmp_ok($o->get_next,'eq','test2','get_next test');
  cmp_ok($o->has_next,'==',0,'has_next check');
  $o->push('test3');
  cmp_ok($o->has_next,'==',1,'has_next check');
  cmp_ok($o->get_next,'eq','test3','get_next test');
  cmp_ok($o->has_next,'==',0,'has_next check');

}
