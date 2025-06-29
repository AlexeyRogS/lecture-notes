#!/usr/bin/perl
use strict;
use warnings;

use File::Path;
use File::Copy;
use File::Find::Rule;

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

    my $htmlname = $_ =~ s\_\-\gr;
    unlink("html/$_.xml");
    rmtree("html/$htmlname");

    my $latexml = "latexml src/$_.tex";
    $latexml .= " --dest=html/$_.xml";
    system($latexml);

    my $latexmlpost = "latexmlpost html/$_.xml";
    $latexmlpost .= " --dest=html/$htmlname/index.html";
    $latexmlpost .= " --sitedirectory=html/$htmlname";
    $latexmlpost .= " --splitat=section";
    $latexmlpost .= " --splitnaming=labelrelative";
    $latexmlpost .= " --navigationtoc=context";
    $latexmlpost .= " --stylesheet=src/lecture-notes.xsl";
    $latexmlpost .= " --nodefaultresources";
    system($latexmlpost);

    my @files = File::Find::Rule->file()->name("sec_*")->in("html/$htmlname/");
    foreach my $file (@files) {
        move($file, $file =~ s/sec_//r);
    }

    my @files = File::Find::Rule->directory->in("html/$htmlname/");
    foreach my $file (@files) {
        move($file, $file =~ s/chap_//r);
    }

    unlink("$_.latexml.log");
    unlink("$_.latexmlpost.log");
}
