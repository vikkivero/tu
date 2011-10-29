package Lamework::Displayer;

use strict;
use warnings;

use base 'Lamework::Base';

sub add_format {
    my $self = shift;
    my ($format, $engine) = @_;

    $self->{formats}->{$format} = $engine;

    return $self;
}

sub render_file {
    my $self = shift;
    my ($file, %args) = @_;

    my ($format) = ($file =~ m{\.([^\.]+)$});

    if (!$format) {
        $file .= '.' . $self->_default_format;
    }

    my $renderer = $self->_get_renderer($format);

    my $body = $renderer->render_file($file, $args{vars} || {});

    if (defined(my $layout = $args{layout} || $self->{layout})) {
        $body =
          $self->render_file($layout,
            vars => {%{$args{vars} || {}}, content => $body});
    }

    return $body;
}

sub render {
    my $self = shift;
    my ($template, %args) = @_;

    my $format   = $args{format};
    my $renderer = $self->_get_renderer($format);

    return $renderer->render($template, $args{vars});
}

sub _default_format {
    my $self = shift;

    my $format = $self->{default_format};
    return $format if $format;

    if (keys(%{$self->{formats}}) == 1) {
        ($format) = keys %{$self->{formats}};
    }
    else {
        die 'No default format defined';
    }

    return $format;
}

sub _get_renderer {
    my $self = shift;
    my ($format) = @_;

    $format ||= $self->_default_format;

    die "Format is required '$format'" unless defined $format;

    return $self->{formats}->{$format};
}

1;