package Data::Range::Compare::Stream::Iterator::Consolidate::Result;

use strict;
use warnings;
use overload '""'=>\&to_string,fallback=>1;

use constant COMMON_RANGE=>0;
use constant START_RANGE=>1;
use constant END_RANGE=>2;

sub new {
  my ($class,$common,$start,$end)=@_;
  bless [$common,$start,$end],$class;
}

sub get_common { $_[0]->[$_[0]->COMMON_RANGE] }
sub get_common_range { $_[0]->[$_[0]->COMMON_RANGE] }
sub get_start { $_[0]->[$_[0]->START_RANGE] }
sub get_start_range { $_[0]->[$_[0]->START_RANGE] }
sub get_end { $_[0]->[$_[0]->END_RANGE] }
sub get_end_range { $_[0]->[$_[0]->END_RANGE] }

sub to_string {
  my ($self)=@_;
  sprintf 'Commoon Range: [%s] Starting range: [%s] Ending Range: [%s]',$self->get_common,$self->get_start,$self->get_end
}


1;
