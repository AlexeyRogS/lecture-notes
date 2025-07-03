% provides layout styles and text environments for lecture notes

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{lecture-notes}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax

\LoadClass[openany,oneside]{book}

% \RequirePackage{fontspec} % loading fontspec breaks the \dbar macro as it is currently defined, will need to fix this if we need fontspec in the future (could use the unicode character U+0111)
\RequirePackage[english]{babel}
\RequirePackage[a4paper]{geometry}
\RequirePackage[indent]{parskip}
\RequirePackage[nottoc]{tocbibind} % add bibliography to table of contents
\RequirePackage{subfiles}
\RequirePackage{enumitem}
\RequirePackage{float}
\RequirePackage{graphicx} % figures
\RequirePackage{amsthm} % automatic numbering of theorem environments and the proof environment
\RequirePackage{tcolorbox} % styling theorem and proof environments

\setcounter{tocdepth}{1}

% ------ environments (theorem, definition, example, etc.)  ------ %

% set up tcolorbox styles
\tcbuselibrary{skins, breakable}

\providecommand*{\fgcolour}{}
\providecommand*{\bgcolour}{}
\newcommand*{\setfgcolour}[1]{
    \renewcommand*{\fgcolour}{#1}
}
\newcommand*{\setbgcolour}[1]{
    \renewcommand*{\bgcolour}{#1}
    \tcbsetforeverylayer{
        enhanced,
        breakable,
        colback=\bgcolour,
        boxrule=0pt,
        frame hidden,
        arc=0pt,
    }
}

% set default colours for styling
\definecolor{darkblue}{rgb}{0.0, 0.2, 0.6}
\definecolor{lightblue}{rgb}{0.8, 0.9, 1}
\setfgcolour{darkblue}
\setbgcolour{lightblue}

% symbol at end of proof
\renewcommand*{\qedsymbol}{$\blacksquare$}

% two different styles of environment
\newtheoremstyle{theoremstyle}{}{}{\itshape}{}{\bfseries\color{\fgcolour}}{}{.5em}{}
\newtheoremstyle{defstyle}{}{}{\upshape}{}{\bfseries\color{\fgcolour}}{.}{.5em}{}

% define numbering for environments
\theoremstyle{theoremstyle}
\newtheorem{theorem}{Theorem}[chapter]
\newtheorem{corollary}{Corollary}[theorem]
\newtheorem*{lemma}{Lemma}

\theoremstyle{defstyle}
\newtheorem{definition}{Definition}[chapter]
\newtheorem{example}{Example}[chapter]

% change colour and style of proof title
% TODO: get rid of this for now as it was messing with the HTML conversion, maybe find a way to bring it back in future
% \renewenvironment{proof}[1][\proofname]{\par
%     \pushQED{\qed}
%     \normalfont \topsep6\p@\@plus6\p@\relax
%     \trivlist
%     \item\relax
%     {\bfseries\color{\fgcolour}#1\@addpunct{.}}\hspace\labelsep\ignorespaces
% }{
%     \popQED\endtrivlist\@endpefalse
% }

% define styles for different environments
\tcolorboxenvironment{theorem}{
    after skip=0pt,
    left=4mm+2pt,
    borderline west={2pt}{0pt}{\fgcolour}
}
\tcolorboxenvironment{proof}{
    before skip=0pt,
    colback=white,
    left=4mm+2pt,
    borderline west={2pt}{0pt}{\fgcolour}
}
\tcolorboxenvironment{corollary}{
    after skip=0pt,
    left=4mm+2pt,
    borderline west={2pt}{0pt}{\fgcolour}
}
\tcolorboxenvironment{lemma}{
    after skip=0pt,
    left=4mm+2pt,
    borderline west={2pt}{0pt}{\fgcolour}
}
\tcolorboxenvironment{definition}{
    borderline={2pt}{0pt}{\fgcolour}
}
\tcolorboxenvironment{example}{}

\endinput
