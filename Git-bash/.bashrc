echo "Hello Felix! Your .bashrc is now active."
echo "type myprogs to list .bashrc info"

###################################################

alias ll='ls -al --color=auto'
alias la='ls -A'
alias myprogs='list_my_programs'
alias whatdoihave='list_my_programs'



###################################################

# Enhanced function to list all aliases and functions
list_my_programs() {
    local bashrc_file="${1:-$HOME/.bashrc}"
    
    if [[ ! -f "$bashrc_file" ]]; then
        echo "Error: .bashrc file not found at $bashrc_file"
        return 1
    fi
    
    echo "=== ALIASES in $bashrc_file ==="
    # Extract alias names with better pattern matching
    grep -E '^[[:space:]]*alias[[:space:]]+[a-zA-Z0-9_]+=' "$bashrc_file" | \
    sed -E 's/^[[:space:]]*alias[[:space:]]+([a-zA-Z0-9_]+)=.*/\1/' | \
    sort | column
    
    echo
    echo "=== FUNCTIONS in $bashrc_file ==="
    # Extract function names (multiple declaration styles)
    grep -E '^[[:space:]]*[a-zA-Z0-9_]+[[:space:]]*\(\)' "$bashrc_file" | \
    sed -E 's/^[[:space:]]*([a-zA-Z0-9_]+)[[:space:]]*\(\)[[:space:]]*\{?.*/\1/' | \
    sort | column
    
    echo
    echo "=== SOURCED FILES ==="
    # Show sourced files for reference
    grep -E '^[[:space:]]*(\.[[:space:]]+|source[[:space:]]+)' "$bashrc_file" | \
    sed -E 's/^[[:space:]]*(\.|source)[[:space:]]+//' | \
    sort | uniq
}



myclone() {
    # Usage: myclone [repository-name] (protocol)
    # Protocol can be 'ssh' or 'https'. Defaults to 'ssh' if not specified.
    
    if [ -z "$1" ]; then
        echo "Error: Please provide a repository name."
        echo "Usage: myclone [repository-name] (ssh|https)"
        return 1
    fi
    
    local repo_name=$1
    local protocol=${2:-ssh} # Default to 'ssh' if second argument is not provided
    
    case $protocol in
        ssh)
            git clone git@github.com:sawicki/$repo_name.git
        ;;
        https)
            git clone https://github.com/sawicki/$repo_name.git
        ;;
        *)
            echo "Error: Protocol must be 'ssh' or 'https'."
            return 1
        ;;
    esac
    
    # If clone was successful, change into the directory
    if [ $? -eq 0 ]; then
        cd "$repo_name"
        echo "Changed into directory: $repo_name"
    fi
}

addrepo() {
    # Usage: addrepo [remote-url] [subdirectory-name]
    # Example: addrepo https://github.com/sawicki/small-tool.git utils/small-tool
    
    if [ $# -ne 2 ]; then
        echo "Error: This function requires two arguments."
        echo "Usage: addrepo [remote-url] [subdirectory-name]"
        echo "Example: addrepo https://github.com/sawicki/small-tool.git utils/small-tool"
        return 1
    fi
    
    local remote_url=$1
    local subdir=$2
    
    echo "Adding remote repository '$remote_url' as subdirectory '$subdir'..."
    git subtree add --prefix="$subdir" "$remote_url" main --squash
    
    # Note: Change 'main' to 'master' if the source repository uses that default branch name
}
# ===== STARTUP MESSAGES =====
echo "type 'myprogs' to list available .bashrc aliases and functions"
