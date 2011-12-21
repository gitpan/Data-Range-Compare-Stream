package Data::Range::Compare::Stream::Iterator::Base;

use strict;
use warnings;

sub new { 
  my ($class,%args)=@_;
  return {%args},$class;
}

sub has_next { 0 }

sub get_next { undef }

1;

