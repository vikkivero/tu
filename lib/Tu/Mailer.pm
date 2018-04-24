package Tu::Mailer;

use strict;
use warnings;

use Carp qw(croak);
use Email::MIME;

use Tu::Mailer::Test;
use Tu::Mailer::Sendmail;
use Tu::Mailer::SMTP;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{subject_prefix} = $params{subject_prefix};
    $self->{signature}      = $params{signature};
    $self->{charset}        = $params{charset} || 'UTF-8';
    $self->{encoding}       = $params{encoding} || 'base64';

    $self->{headers} = $params{headers} || [];

    $self->{transport} = $params{transport};
    croak 'transport required' unless $self->{transport};

    return $self;
}

sub send {
    my $self = shift;
    my (%params) = @_;

    my $message = $self->build_message(%params);

    my $transport = $self->_build_transport($self->{transport});

    $transport->send_message($message);

    return $self;
}

sub build_message {
    my $self = shift;
    my (%params) = @_;

    if (defined(my $signature = $self->{signature}) && $params{body}) {
        $params{body} .= "\n\n-- \n$signature";
    }
    my $parts =
      $params{body}
      ? [
        Email::MIME->create(
            attributes => {
                content_type => 'text/plain',
                charset      => $self->{charset},
                encoding     => $self->{encoding}
            },
            body_str => $params{body}
        )
      ]
      : ($params{parts} || []);

    my $message = Email::MIME->create(attributes => $params{attributes}, parts => $parts);

    my @headers = (@{$self->{headers}}, @{$params{headers} || []});
    $self->_set_headers($message, \@headers);

    $message->charset_set($self->{charset});

    return $message->as_string;
}

sub _build_transport {
    my $self = shift;
    my ($options) = @_;

    my $name = $options->{name};

    if ($name eq 'test') {
        return Tu::Mailer::Test->new(%$options);
    }
    elsif ($name eq 'sendmail') {
        return Tu::Mailer::Sendmail->new(%$options);
    }
    elsif ($name eq 'smtp') {
        return Tu::Mailer::SMTP->new(%$options);
    }
    elsif ($name eq 'smtp+tls') {
        return Tu::Mailer::SMTP->new(ssl => 'starttls', %$options);
    }
    else {
        croak 'Unknown transport';
    }
}

sub _set_headers {
    my $self = shift;
    my ($message, $headers) = @_;

    while (my ($key, $value) = splice(@$headers, 0, 2)) {
        if ($key eq 'Subject' && (my $prefix = $self->{subject_prefix})) {
            $value = $prefix . ' ' . $value;
        }

        $message->header_str_set($key => $value);
    }
}

1;
