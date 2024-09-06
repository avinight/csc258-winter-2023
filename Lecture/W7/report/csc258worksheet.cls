% csc258lab.cls
%
% A LaTeX2e document class for CSC258H1 lab materials.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{csc258worksheet}

% Inherit from scrreprt.
\LoadClass[twoside,parskip=full]{scrreprt}

%% Package Loading %%

\RequirePackage{calc}       % Calculate things about the page layout.
\RequirePackage{geometry}   % Page Layout (margins).
\RequirePackage{setspace}   % Line Spacing.
\RequirePackage{textcase}   % Convert between lower/upper case.
\RequirePackage{microtype}  % Typography things.
\RequirePackage{tcolorbox}
\RequirePackage{enumitem}
\RequirePackage{listings}
\RequirePackage{fancyvrb}

\PassOptionsToPackage{scrlayer-scrpage}{automark}
\RequirePackage{scrlayer-scrpage} % To customize the headers/footers of different page styles.
\automark[chapter]{chapter}

\RequirePackage{scrhack} % To fix compatibility issues with KOMA script and other packages.


% Prettier tables
\RequirePackage{booktabs,tabularx}
\renewcommand\tabularxcolumn[1]{m{#1}}
\newcolumntype{Z}[0]{>{\centering\arraybackslash}X}%
\newcolumntype{s}[0]{>{\hsize=.4\hsize}Z}%
\newcolumntype{n}[0]{>{\hsize=.8\hsize}Z}%

%% Page Margins %%
\geometry{
    top = 0.75in,
    bottom = 0.75in,
    right = 0.75in,
    left = 0.75in,
}

%% Header and Footer %%
\clearpairofpagestyles
\pagenumbering{arabic}

\addtokomafont{pageheadfoot}{\normalfont\sffamily}

\renewcommand*{\chaptermarkformat}{}
\renewcommand*{\sectionmarkformat}{}
\renewcommand*\thesection{\arabic{section}}

% Show section/chapter titles in the header
\automark[section]{section}

\DeclareRobustCommand{\AllCapsSpaced}[1]{\textls[160]{\MakeTextUppercase{#1}}}

\renewcommand{\chapterlinesformat}[3]{%
\parbox[b]{\textwidth}{\hfill \AllCapsSpaced{#3}}\par%
\rule{\textwidth}{.4pt}\par%
}

\setkomafont{dictumtext}{\itshape\small}
\setkomafont{dictumauthor}{\normalfont}
\renewcommand*\dictumwidth{\linewidth}
\renewcommand*\dictumauthorformat[1]{--- #1}
\renewcommand*\dictumrule{}
