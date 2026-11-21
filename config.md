@def author = "The Julia Project"

\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}

@def generate_rss = false

\newcommand{\style}[2]{~~~<div style="!#1;margin-left:auto;margin-right:auto;">~~~!#2~~~</div>~~~}

<!-- Build files, not site content: the Julia project, and the npm files CI creates -->
@def ignore = ["Project.toml", "Manifest.toml", "package.json", "package-lock.json"]
