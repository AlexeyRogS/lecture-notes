#!/usr/bin/perl
use strict;
use warnings;

my @notes = (
    "real_analysis",
    "classical_mechanics",
    "abstract_algebra",
    "quantum_mechanics",
    "computational_physics",
    "multivariate_calculus",
    "thermodynamics"
);

foreach (@notes) {
    system("latexmk
        -xelatex
        -cd
        -synctex=1
        -outdir=../pdf
        -interaction=nonstopmode
        -file-line-error
        src/$_.tex"
    );

    system("latexmk 
        -c
        -cd
        -outdir=../pdf
        src/$_.tex"
    );

    my $latexml = "latexml src/$_.tex";
    $latexml .= " --dest=html/$_.xml";
    system($latexml);

    my $latexmlpost = "latexmlpost html/$_.xml";
    $latexmlpost .= " --dest=html/$_/$_.html";
    $latexmlpost .= " --sitedirectory=html/$_";
    $latexmlpost .= " --splitat=section";
    $latexmlpost .= " --nodefaultresources";
    system($latexmlpost);

    unlink("$_.latexml.log");
    unlink("$_.latexmlpost.log");
}
