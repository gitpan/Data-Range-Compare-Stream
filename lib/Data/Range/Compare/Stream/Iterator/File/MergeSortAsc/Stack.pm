package Data::Range::Compare::Stream::Iterator::File::MergeSortAsc::Stack;
use strict;
use warnings;
use Data::Dumper;

use IO::File;
use File::Temp qw/ :seekable /;

sub new {
   my ($class)=@_;
   return bless {next_stack=>File::Temp->new(UNLINK=>0),next_stack_count=>0,stack_count=>0},$class;
}

sub push {
  my ($self,$todo)=@_;
  $self->{next_stack}->print($todo."\n");
  $self->{next_stack_count}++;

}

sub has_next {
  my ($self)=@_;
  if($self->{stack_count}>1) {
    return 2;
  } else {
    my $total=$self->{stack_count} + $self->{next_stack_count};
    return 2 if $total>1;
    return 1 if $total==1;
  }
  return 0;
}

sub roll_stack {
  my ($self)=@_;
  if(defined($self->{stack})) {
    $self->{stack}->close ;
    unlink $self->{stack}->filename;
  }
  $self->{stack_count}=$self->{next_stack_count};
  $self->{next_stack_count}=0;
  $self->{stack}=$self->{next_stack};
  $self->{stack}->flush;
  seek($self->{stack},0,0);
  $self->{next_stack}=File::Temp->new(UNLINK=>0);
}

sub get_next {
  my ($self)=@_;
  $self->roll_stack unless defined($self->{stack});
  $self->roll_stack if $self->{stack_count}==0;

  my $next=$self->{stack}->getline;
  --$self->{stack_count};
  chomp($next);

  return $next;
}

sub DESTROY {
  my ($self)=@_;
  return unless defined($self);
  if(defined($self->{stack})) {
    my $name=$self->{stack}->filename;
    $self->{stack}->close;
    unlink $name;
  }
  if(defined($self->{next_stack})) {
    my $name=$self->{next_stack}->filename;
    $self->{next_stack}->close;
    unlink $name;
  }
}
1;
