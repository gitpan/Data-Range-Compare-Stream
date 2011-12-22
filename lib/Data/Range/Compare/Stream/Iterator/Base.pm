package Data::Range::Compare::Stream::Iterator::Base;

use strict;
use warnings;
use overload '""'=>\&to_string,fallback=>1;

sub new { 
  my ($class,%args)=@_;
  return bless {%args},$class;
}

sub has_next { $_[0]->{has_next} }

sub get_next { undef }

sub to_string { ref($_[0]) }


1;

