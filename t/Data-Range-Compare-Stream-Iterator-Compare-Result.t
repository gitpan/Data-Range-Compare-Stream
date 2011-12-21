# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Data-Range-Compare-Stream.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use Data::Dumper;
use Test::More tests => 41;

BEGIN { use_ok('Data::Range::Compare::Stream') };
BEGIN { use_ok('Data::Range::Compare::Stream::Iterator::Consolidate::Result') };
BEGIN { use_ok('Data::Range::Compare::Stream::Iterator::Compare::Result') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

#
# Basic Constructor tests
{
  my $obj=new Data::Range::Compare::Stream::Iterator::Compare::Result;
  ok(defined($obj),'Should get an object back from the constructor!');
}
{
  my $obj=Data::Range::Compare::Stream::Iterator::Compare::Result->new;
  ok(defined($obj),'Should get an object back from the constructor with the ->new syntax!');
}

# 
# Instance interface tests non empty non full 
{
  my $columns=[];
  my $column_count=0;
  my $overlap_count=0;
  my $overlap_ids=[];
  my $non_overlap_ids=[];
  my $common=new Data::Range::Compare::Stream(1,1);
  for(0 .. 1) {
    my $common=new Data::Range::Compare::Stream(1,1);
    my $start=new Data::Range::Compare::Stream(0,1);
    my $end=new Data::Range::Compare::Stream(1,2);
    my $consolidate=new Data::Range::Compare::Stream::Iterator::Consolidate::Result($common,$start,$end);

    push @$columns,$consolidate;
    push @$overlap_ids,$#$columns;
    $overlap_count++;

    push @$columns,undef;
    push @$non_overlap_ids,$#$columns;
    $column_count +=2;
  }

  my $obj=new  Data::Range::Compare::Stream::Iterator::Compare::Result(
    $common,
    $columns,
    $overlap_count,
    $overlap_ids,
    $non_overlap_ids,
  );

  cmp_ok($obj->get_column_count,'==',4,'Should have 4 columns');
  cmp_ok($obj->get_overlap_count,'==',2,'Should have a total of 2 overlapping columns');
  cmp_ok($obj->get_non_overlap_count,'==',2,'Should have a total of 2 non overlapping columns');
  ok(!$obj->is_empty,'object should not show empty');
  ok(!$obj->is_full,'object should not show full');
  {
    my $overlap_ids=$obj->get_overlap_ids;
    cmp_ok($#$overlap_ids,'==',1,'should have a last index id of 1 when looking at the total overlap id count');
    cmp_ok($overlap_ids->[0],'==',0,'column 0 should show as being the first overlap id');
    cmp_ok($overlap_ids->[1],'==',2,'column 2 should show as being the second overlap id');
    {
      my $column=$overlap_ids->[0];
      my $result=$obj->get_consolidator_result_by_id($column);
      ok(defined($result),'should get an object for column 0');
      cmp_ok($result->get_common,'eq','1 - 1',"Should get a range of 1 - 1");
    }
    {
      my $column=$overlap_ids->[1];
      my $result=$obj->get_consolidator_result_by_id($column);
      ok(defined($result),'should get an object for column 1');
      cmp_ok($result->get_common,'eq','1 - 1',"Should get a range of 1 - 1");
    }
  }
  {
    my $non_overlap_ids=$obj->get_non_overlap_ids;
    cmp_ok($#$non_overlap_ids,'==',1,'should have a last index id of 1 when looking at the total of non overlap id counts');
    cmp_ok($non_overlap_ids->[0],'==',1,'column 0 should be 1');
    cmp_ok($non_overlap_ids->[1],'==',3,'column 1 should be 3');
    {
      my $column=$non_overlap_ids->[0];
      my $result=$obj->get_consolidator_result_by_id($column);
      ok(!defined($result),'should get nothing for column 0');
    }
    {
      my $column=$non_overlap_ids->[1];
      my $result=$obj->get_consolidator_result_by_id($column);
      ok(!defined($result),'should get nothing for column 0');
    }
  }
}

{
  my $columns=[];
  my $column_count=0;
  my $overlap_count=0;
  my $overlap_ids=[];
  my $non_overlap_ids=[];
  my $common=new Data::Range::Compare::Stream(1,1);
  for(0 .. 1) {
    my $common=new Data::Range::Compare::Stream(1,1);
    my $start=new Data::Range::Compare::Stream(0,1);
    my $end=new Data::Range::Compare::Stream(1,2);
    my $consolidate=new Data::Range::Compare::Stream::Iterator::Consolidate::Result($common,$start,$end);

    push @$columns,$consolidate;
    push @$overlap_ids,$#$columns;
    $overlap_count++;
    $column_count +=1;
  }

  my $obj=new  Data::Range::Compare::Stream::Iterator::Compare::Result(
    $common,
    $columns,
    $overlap_count,
    $overlap_ids,
    $non_overlap_ids,
  );

  cmp_ok($obj->get_column_count,'==',2,'Should have 2 columns');
  cmp_ok($obj->get_overlap_count,'==',2,'Should have a total of 2 overlapping columns');
  cmp_ok($obj->get_non_overlap_count,'==',0,'Should have a total of 0 non overlapping columns');
  ok(!$obj->is_empty,'object should not show empty');
  ok($obj->is_full,'object should show full');
  {
    my $overlap_ids=$obj->get_overlap_ids;
    cmp_ok($#$overlap_ids,'==',1,'should have a last index id of 1 when looking at the total overlap id count');
    cmp_ok($overlap_ids->[0],'==',0,'column 0 should show as being the first overlap id');
    cmp_ok($overlap_ids->[1],'==',1,'column 1 should show as being the second overlap id');
    {
      my $column=$overlap_ids->[0];
      my $result=$obj->get_consolidator_result_by_id($column);
      ok(defined($result),'should get an object for column 0');
      cmp_ok($result->get_common,'eq','1 - 1',"Should get a range of 1 - 1");
    }
    {
      my $column=$overlap_ids->[1];
      my $result=$obj->get_consolidator_result_by_id($column);
      ok(defined($result),'should get an object for column 1');
      cmp_ok($result->get_common,'eq','1 - 1',"Should get a range of 1 - 1");
    }
  }
  {
    my $non_overlap_ids=$obj->get_non_overlap_ids;
    cmp_ok($#$non_overlap_ids,'==',-1,'should have a last index id of -1 when looking at the total of non overlap id counts');
  }
}
{
  my $columns=[];
  my $column_count=0;
  my $overlap_count=0;
  my $overlap_ids=[];
  my $non_overlap_ids=[];
  my $common=new Data::Range::Compare::Stream(1,1);
  for(0 .. 1) {
    my $common=new Data::Range::Compare::Stream(1,1);
    my $start=new Data::Range::Compare::Stream(0,1);
    my $end=new Data::Range::Compare::Stream(1,2);

    push @$columns,undef;
    push @$non_overlap_ids,$#$columns;
    $column_count +=1;
  }

  my $obj=new  Data::Range::Compare::Stream::Iterator::Compare::Result(
    $common,
    $columns,
    $overlap_count,
    $overlap_ids,
    $non_overlap_ids,
  );

  cmp_ok($obj->get_column_count,'==',2,'Should have 2 columns');
  cmp_ok($obj->get_overlap_count,'==',0,'Should have a total of 0 overlapping columns');
  cmp_ok($obj->get_non_overlap_count,'==',2,'Should have a total of 2 non overlapping columns');
  ok($obj->is_empty,'object should show empty');
  ok(!$obj->is_full,'object should not show full');
  {
    my $non_overlap_ids=$obj->get_non_overlap_ids;
    cmp_ok($#$non_overlap_ids,'==',1,'should have a last index id of 1 when looking at the total of non overlap id counts');
  }
}
