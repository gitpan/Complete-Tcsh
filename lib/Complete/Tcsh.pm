package Complete::Tcsh;

our $DATE = '2014-11-23'; # DATE
our $VERSION = '0.01'; # VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       parse_cmdline
                       format_completion
               );

require Complete::Bash;

our %SPEC;

$SPEC{parse_cmdline} = {
    v => 1.1,
    summary => 'Parse shell command-line for processing by completion routines',
    description => <<'_',

This function converts COMMAND_LINE (str) given by tcsh to become something like
COMP_WORDS (array) and COMP_CWORD (int), like what bash supplies to shell
functions. Currently implemented using `Complete::Bash`'s `parse_cmdline`.

_
    args_as => 'array',
    args => {
        cmdline => {
            summary => 'Command-line, defaults to COMMAND_LINE environment',
            schema => 'str*',
            pos => 0,
        },
    },
    result => {
        schema => ['array*', len=>2],
        description => <<'_',

Return a 2-element array: `[$words, $cword]`. `$words` is array of str,
equivalent to `COMP_WORDS` provided by bash to shell functions. `$cword` is an
integer, equivalent to `COMP_CWORD` provided by bash to shell functions. The
word to be completed is at `$words->[$cword]`.

Note that COMP_LINE includes the command name. If you want the command-line
arguments only (like in `@ARGV`), you need to strip the first element from
`$words` and reduce `$cword` by 1.

_
    },
    result_naked => 1,
};
sub parse_cmdline {
    my ($line) = @_;

    $line //= $ENV{COMMAND_LINE};
    Complete::Bash::parse_cmdline($line, length($line));
}

$SPEC{format_completion} = {
    v => 1.1,
    summary => 'Format completion for output (for shell)',
    description => <<'_',

tcsh accepts completion reply in the form of one entry per line to STDOUT.
Currently the formatting is done using `Complete::Bash`'s `format_completion`
because escaping rule and so on are not yet well defined in tcsh.

_
    args_as => 'array',
    args => {
        shell_completion => {
            summary => 'Result of shell completion',
            description => <<'_',

Either an array or hash.

_
            schema=>['any*' => of => ['hash*', 'array*']],
            req=>1,
            pos=>0,
        },
        as => {
            schema => ['str*', in=>['string', 'array']],
            default => 'string',
        },
    },
    result => {
        summary => 'Formatted string (or array, if `as` is set to `array`)',
        schema => ['any*' => of => ['str*', 'array*']],
    },
    result_naked => 1,
};
sub format_completion {
    Complete::Bash::format_completion(@_);
}

1;
#ABSTRACT: Completion module for tcsh shell

__END__

=pod

=encoding UTF-8

=head1 NAME

Complete::Tcsh - Completion module for tcsh shell

=head1 VERSION

This document describes version 0.01 of Complete::Tcsh (from Perl distribution Complete-Tcsh), released on 2014-11-23.

=head1 DESCRIPTION

tcsh allows completion to come from various sources. One of the simplest is from
a list of words:

 % complete CMDNAME 'p/*/(one two three)/'

Another source is from an external command:

 % complete CMDNAME 'p/*/`mycompleter --somearg`/'

The command receives one environment variables C<COMMAND_LINE> (string, raw
command-line). Unlike bash, tcsh does not (yet) provide something akin to
C<COMP_POINT> in bash. Command is expected to print completion entries, one line
at a time.

 % cat mycompleter
 #!/usr/bin/perl
 use Complete::Tcsh qw(parse_cmdline format_completion);
 use Complete::Util qw(complete_array_elem);
 my ($words, $cword) = parse_cmdline();
 my $res = complete_array_elem(array=>[qw/--help --verbose --version/], word=>$words->[$cword]);
 print format_completion($res);

 % complete -C foo-complete foo
 % foo --v<Tab>
 --verbose --version

This module provides routines for you to be doing the above.

Also, unlike bash, currently tcsh does not allow delegating completion to a
shell function.

=head1 FUNCTIONS


=head2 format_completion($shell_completion, $as) -> array|str

Format completion for output (for shell).

tcsh accepts completion reply in the form of one entry per line to STDOUT.
Currently the formatting is done using C<Complete::Bash>'s C<format_completion>
because escaping rule and so on are not yet well defined in tcsh.

Arguments ('*' denotes required arguments):

=over 4

=item * B<as> => I<str> (default: "string")

=item * B<shell_completion>* => I<array|hash>

Result of shell completion.

Either an array or hash.

=back

Return value:

Formatted string (or array, if `as` is set to `array`) (any)


=head2 parse_cmdline($cmdline) -> array

Parse shell command-line for processing by completion routines.

This function converts COMMAND_LINE (str) given by tcsh to become something like
COMP_WORDS (array) and COMP_CWORD (int), like what bash supplies to shell
functions. Currently implemented using C<Complete::Bash>'s C<parse_cmdline>.

Arguments ('*' denotes required arguments):

=over 4

=item * B<cmdline> => I<str>

Command-line, defaults to COMMAND_LINE environment.

=back

Return value:

 (array)

Return a 2-element array: `[$words, $cword]`. `$words` is array of str,
equivalent to `COMP_WORDS` provided by bash to shell functions. `$cword` is an
integer, equivalent to `COMP_CWORD` provided by bash to shell functions. The
word to be completed is at `$words->[$cword]`.

Note that COMP_LINE includes the command name. If you want the command-line
arguments only (like in `@ARGV`), you need to strip the first element from
`$words` and reduce `$cword` by 1.

=head1 TODOS

=head1 SEE ALSO

L<Complete>

L<Complete::Bash>

tcsh manual.

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Complete-Tcsh>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Complete-Tcsh>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Complete-Tcsh>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
