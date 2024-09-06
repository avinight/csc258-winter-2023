% csc258lab.cls
%
% A LaTeX2e document class for CSC258H1 lab handouts.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{csc258lab}

% Inherit from scrreprt.
\LoadClass[
    twoside,
    titlepage=false,
    numbers=noenddot,
    parskip=full
    ]{scrreprt}

%% Package Loading %%

\RequirePackage{calc}       % Calculate things about the page layout.
\RequirePackage{geometry}   % Page Layout (margins).
\RequirePackage{setspace}   % Line Spacing.
\RequirePackage{textcase}   % Convert between lower/upper case.
\RequirePackage{microtype}  % Typography things.
\RequirePackage{ifthenx}    % if-else support

\RequirePackage{graphicx}
\RequirePackage{tcolorbox}
\RequirePackage{enumitem}
\RequirePackage{tikz}

\PassOptionsToPackage{scrlayer-scrpage}{automark}
\RequirePackage{scrlayer-scrpage} % To customize the headers/footers of different page styles.
\automark[chapter]{chapter}

\RequirePackage{scrhack} % To fix compatibility issues with KOMA script and other packages.

%% Page Margins %%
\geometry{
    top = 0.75in,
    bottom = 0.75in,
    right = 0.75in,
    left = 0.75in,
}

%% Spacing around section headings %%
\RedeclareSectionCommands[
  beforeskip=-.5\baselineskip,
  afterskip=.25\baselineskip
]{section,subsection,subsubsection}
\RedeclareSectionCommands[
  beforeskip=.5\baselineskip,
  afterskip=-1em
]{paragraph,subparagraph}

%% Header and Footer %%
\clearpairofpagestyles
\pagenumbering{arabic}

\addtokomafont{pageheadfoot}{\normalfont\sffamily}

\renewcommand*{\sectionmarkformat}{}
\automark[section]{section}

\lehead[]{\headmark}
\lohead[]{\headmark}
\rehead[]{\pagemark}
\rohead[]{\pagemark}

\cfoot{Copyright \textcopyright{} \the\year{} Steven Engels and Mario Badr}

% \renewcommand*{\chapterpagestyle}{scrheadings}

\renewcommand{\chapterlinesformat}[3]{%
\parbox[b]{\textwidth}{\hfill \AllCapsSpaced{Lab #2}}\par%
\rule{\textwidth}{.4pt}\par
\AllCapsSpaced{#3}%
}

\DeclareRobustCommand{\AllCapsSpaced}[1]{\textls[160]{\MakeTextUppercase{#1}}}

\setkomafont{dictumtext}{\itshape\small}
\setkomafont{dictumauthor}{\normalfont}
\renewcommand*\dictumwidth{\linewidth}
\renewcommand*\dictumauthorformat[1]{--- #1}
\renewcommand*\dictumrule{}
