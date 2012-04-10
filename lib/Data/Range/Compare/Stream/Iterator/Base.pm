package Data::Range::Compare::Stream::Iterator::Base;

use strict;
use warnings;
use overload '""'=>\&to_string,fallback=>1;

sub new { 
  my ($class,%args)=@_;
  return bless {%args},$class;
}

sub on_consolidate { }

sub has_next { $_[0]->{has_next} }

sub get_next { undef }

sub to_string { ref($_[0]) }

sub delete_from_root { }

sub get_child_column_id { undef }

sub get_child { undef }

sub set_column_id { $_[0]->{column_id}=$_[1] }

sub get_column_id { $_[0]->{column_id} }

sub get_root_column_id {$_[0]->get_column_id }

sub get_root { $_[0] }

sub is_child { 0 }
sub has_child { 0 }
sub is_root { 1 }
sub has_root {0}


1;

