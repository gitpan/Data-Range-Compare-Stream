#!/usr/bin/perl

# custom package from FILE_EXAMPLE.pl
use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>54;

BEGIN { use_ok('Data::Range::Compare::Stream::Iterator::Compare::ColumnRelations') }

use Data::Range::Compare::Stream::Iterator::Compare::Asc;
use Data::Range::Compare::Stream::Iterator::Consolidate;
use Data::Range::Compare::Stream;
use Data::Range::Compare::Stream::Iterator::Consolidate::OverlapAsColumn;

{

  my $obj=Data::Range::Compare::Stream::Iterator::Array->new();
  my @range_set_a=qw(
   0 0
   0 0

   1 4
   2 3
   4 5

   10 20
   11 19
   12 18

  );
  my @ranges;
  while(my ($start,$end)=splice(@range_set_a,0,2)) {
    $obj->create_range($start,$end);
  }
  $obj->prepare_for_consolidate_asc;
  my $cmp=new Data::Range::Compare::Stream::Iterator::Compare::Asc;
  my $column_a=Data::Range::Compare::Stream::Iterator::Consolidate::OverlapAsColumn->new($obj,$cmp);
  $cmp->add_consolidator($column_a);
  my $relations=new Data::Range::Compare::Stream::Iterator::Compare::ColumnRelations($cmp);
  
  {
    ok($cmp->has_next,'should have next');
    my $result=$cmp->get_next;
    my $columns=$relations->get_root_results($result);
    cmp_ok(join(',',@{$relations->get_root_ids}),'eq','0','Root_ids check');
    cmp_ok($result->get_common,'eq','0 - 0','common range check');
    is_deeply(['0 - 0','0 - 0' ],[ map { $_->get_common."" } (map { @$_ } @{$columns}{ @{$relations->get_root_ids}  })],'column mapping');
    my $ids=$relations->get_root_result_ids($result);
    is_deeply({0=>[0,1]},$ids,'Column id Map check');
    
  }

  {
    ok($cmp->has_next,'should have next');
    my $result=$cmp->get_next;
    my $columns=$relations->get_root_results($result);
    cmp_ok(join(',',@{$relations->get_root_ids}),'eq','0','Root_ids check');
    cmp_ok($result->get_common,'eq','1 - 1','common range check');
    is_deeply(['1 - 4' ],[ map { $_->get_common."" } (map { @$_ } @{$columns}{ @{$relations->get_root_ids}  })],'column mapping');
    is_deeply({0=>[0]},$relations->get_root_result_ids($result),'Column id Map check');
  }
  {
    ok($cmp->has_next,'should have next');
    my $result=$cmp->get_next;
    my $columns=$relations->get_root_results($result);
    cmp_ok(join(',',@{$relations->get_root_ids}),'eq','0','Root_ids check');
    cmp_ok($result->get_common,'eq','2 - 3','common range check');
    is_deeply(['1 - 4','2 - 3' ],[ map { $_->get_common."" } (map { @$_ } @{$columns}{ @{$relations->get_root_ids}  })],'column mapping');
    is_deeply({0=>[0,1]},$relations->get_root_result_ids($result),'Column id Map check');
    
  }
  {
    ok($cmp->has_next,'should have next');
    my $result=$cmp->get_next;
    my $columns=$relations->get_root_results($result);
    cmp_ok(join(',',@{$relations->get_root_ids}),'eq','0','Root_ids check');
    cmp_ok($result->get_common,'eq','4 - 4','common range check');
    is_deeply(['1 - 4','4 - 5' ],[ map { $_->get_common."" } (map { @$_ } @{$columns}{ @{$relations->get_root_ids}  })],'column mapping');
    is_deeply({0=>[0,1]},$relations->get_root_result_ids($result),'Column id Map check');
    
  }
  {
    ok($cmp->has_next,'should have next');
    my $result=$cmp->get_next;
    my $columns=$relations->get_root_results($result);
    cmp_ok(join(',',@{$relations->get_root_ids}),'eq','0','Root_ids check');
    cmp_ok($result->get_common,'eq','5 - 5','common range check');
    is_deeply(['4 - 5' ],[ map { $_->get_common."" } (map { @$_ } @{$columns}{ @{$relations->get_root_ids}  })],'column mapping');
    is_deeply({0=>[1]},$relations->get_root_result_ids($result),'Column id Map check');
    
  }
  {
    ok($cmp->has_next,'should have next');
    my $result=$cmp->get_next;
    ok($result->is_empty,'result should be empty!');
  }
  {
    ok($cmp->has_next,'should have next');
    my $result=$cmp->get_next;
    my $columns=$relations->get_root_results($result);
    cmp_ok(join(',',@{$relations->get_root_ids}),'eq','0','Root_ids check');
    cmp_ok($result->get_common,'eq','10 - 10','common range check');
    is_deeply(['10 - 20' ],[ map { $_->get_common."" } (map { @$_ } @{$columns}{ @{$relations->get_root_ids}  })],'column mapping');
    is_deeply({0=>[0]},$relations->get_root_result_ids($result),'Column id Map check');
    
  }
  {
    ok($cmp->has_next,'should have next');
    my $result=$cmp->get_next;
    my $columns=$relations->get_root_results($result);
    cmp_ok(join(',',@{$relations->get_root_ids}),'eq','0','Root_ids check');
    cmp_ok($result->get_common,'eq','11 - 11','common range check');
    is_deeply(['10 - 20','11 - 19' ],[ map { $_->get_common."" } (map { @$_ } @{$columns}{ @{$relations->get_root_ids}  })],'column mapping');
    is_deeply({0=>[0,1]},$relations->get_root_result_ids($result),'Column id Map check');
    
  }
  {
    ok($cmp->has_next,'should have next');
    my $result=$cmp->get_next;
    my $columns=$relations->get_root_results($result);
    cmp_ok(join(',',@{$relations->get_root_ids}),'eq','0','Root_ids check');
    cmp_ok($result->get_common,'eq','12 - 18','common range check');
    is_deeply(['10 - 20','11 - 19','12 - 18' ],[ map { $_->get_common."" } (map { @$_ } @{$columns}{ @{$relations->get_root_ids}  })],'column mapping');
    is_deeply({0=>[0,1,2]},$relations->get_root_result_ids($result),'Column id Map check');
  }
  {
    ok($cmp->has_next,'should have next');
    my $result=$cmp->get_next;
    my $columns=$relations->get_root_results($result);
    cmp_ok(join(',',@{$relations->get_root_ids}),'eq','0','Root_ids check');
    cmp_ok($result->get_common,'eq','19 - 19','common range check');
    is_deeply(['10 - 20','11 - 19'],[ map { $_->get_common."" } (map { @$_ } @{$columns}{ @{$relations->get_root_ids}  })],'column mapping');
    is_deeply({0=>[0,1]},$relations->get_root_result_ids($result),'Column id Map check');
    
  }
  {
    ok($cmp->has_next,'should have next');
    my $result=$cmp->get_next;
    my $columns=$relations->get_root_results($result);
    cmp_ok(join(',',@{$relations->get_root_ids}),'eq','0','Root_ids check');
    cmp_ok($result->get_common,'eq','20 - 20','common range check');
    is_deeply(['10 - 20',],[ map { $_->get_common."" } (map { @$_ } @{$columns}{ @{$relations->get_root_ids}  })],'column mapping');
    is_deeply({0=>[0]},$relations->get_root_result_ids($result),'Column id Map check');
    
  }
  ok(!$cmp->has_next,'cmpare should be empty!');

}
