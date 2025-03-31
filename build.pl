#!/usr/bin/perl
use strict;
use warnings;

my @notes = (
    "real_analysis",
    "newtonian_mechanics",
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
}
