source scl_source enable rh-nodejs10

function y { PROJECT_PATH=`pwd` npm run --prefix ../landscapeapp "$@"; }
export -f y
# yf does a normal build and full test run
alias yf='y fetch'
alias yl='y check-links'
alias yq='y remove-quotes'
alias yp='y build && y open:dist'
# yo does a quick build and opens up the landscape in your browser
alias yo='y open:src'