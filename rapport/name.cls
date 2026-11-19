\LoadClass[a4paper,11pt]{article} % Classe du document

%---------- Packages ----------------

\RequirePackage[french]{babel} %Langue du document
\RequirePackage[utf8]{inputenc} %Caractères spéciaux
\RequirePackage[section]{placeins}%Pour placement de section
\RequirePackage[T1]{fontenc} %Quelques lettres qui sont pas inclus dans UTF-8
\RequirePackage{mathtools} %Paquet pour des équations et symboles mathématiques
\RequirePackage{siunitx} %Pour écrire avec la notation scientifique (Ex.: \num{2e+9})
\RequirePackage{float} %Pour placement d'images
\RequirePackage{graphicx} %Paquet pour insérer des images
\RequirePackage[justification=centering]{caption} %Pour les légendes centralisées
\RequirePackage{subcaption}
\RequirePackage{wallpaper}
\RequirePackage{nomencl}
\RequirePackage{fancyhdr}
\RequirePackage{url}
\RequirePackage[hidelinks,pdfpagelabels=true,plainpages=false]{hyperref}
\RequirePackage[left=2.5cm,right=2.5cm,top=2.5cm,bottom=2.5cm,headheight=45pt]{geometry} %Configuration de la page

\usepackage{sectsty}
\usepackage{xcolor}

% On définit les deux couleurs utilisées
\definecolor{couleur_section}{RGB}{0,0,128}
\definecolor{couleur_subsection}{RGB}{0,128,255}

% On personnalise chacun des titres à l'aide des commandes "sectionfont", "subsectionfont", etc.
\sectionfont{\color{couleur_section}}
\subsectionfont{\color{couleur_subsection}}
\subsubsectionfont{\itshape}

%------- Informations sur le rapport----------

\newcommand{\UE}[1]{\def\UEval{#1}}
\newcommand{\sujet}[1]{\def\sujetval{#1}}
\newcommand{\titre}[1]{\def\titreval{#1}}
\newcommand{\enseignant}[1]{\def\enseignantval{#1}}
\newcommand{\enseignantenseirb}[1]{\def\enseignantenseirbval{#1}}
\newcommand{\eleves}[1]{\def\elevesval{#1}}
\newcommand{\dateRapport}[1]{\def\dateval{#1}}

\newcommand{\UEval}{}
\newcommand{\sujetval}{}
\newcommand{\titreval}{}
\newcommand{\enseignantval}{}
\newcommand{\enseignantenseirbval}{}
\newcommand{\elevesval}{}
\newcommand{\dateval}{Année 2026-2027}

\newcommand{\fairemarges}{
\makenomenclature
\pagestyle{fancy}
\fancyheadoffset{0cm}
\setlength{\headheight}{45pt}
\lhead{\includegraphics[height=1.0cm]{logo_enseirb.jpeg}}
\rhead{\includegraphics[height=1.0cm]{insa_logo.png}}
\chead{}
\lfoot{\footnotesize\itshape\titreval}
\cfoot{}
\rfoot{\thepage}
}

\newcommand{\fairepagedegarde}{
\begin{titlepage}
	\centering
	\includegraphics[width=0.45\textwidth]{logo_enseirb.jpeg}\hfill
	\includegraphics[width=0.45\textwidth]{insa_logo.png}\par\vspace{1.5cm}
	
	\ifx\UEval\@empty\else{\scshape\Large \UEval \par}\vspace{0.5cm}\fi
	\ifx\sujetval\@empty\else{\scshape\large \sujetval \par}\vspace{0.5cm}\fi
	
	\vspace{1cm}
	\rule{\linewidth}{0.4 mm} \\[0.4 cm]
	{\huge\bfseries \titreval \par}
	\rule{\linewidth}{0.4 mm} \\[1.5 cm]
    
	\begin{minipage}[t]{0.48\textwidth}
		\begin{flushleft} \large
		\emph{\textbf{Auteurs :}}\\[0.3cm]
		\elevesval
		\end{flushleft}
	\end{minipage}
	\hfill
	\begin{minipage}[t]{0.48\textwidth}
		\begin{flushright} \large
		\emph{\textbf{Sous la supervision de :}}\\[0.3cm]
		\enseignantval
		\end{flushright}
	\end{minipage}
    
	\vfill
	{\large \dateval \par}
\end{titlepage}
}

\newcommand{\tabledematieres}{
\tableofcontents
\newpage
}

\newcommand{\insererfigure}[4]{
\begin{figure}[ht]
\centering
\includegraphics[height=#2]{#1}
\caption{#3}
\label{fig: #4}
\end{figure}
}
