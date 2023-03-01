agent { 
    policy = "read"
} 

node { 
    policy = "read" 
} 

namespace "*" { 
    policy = "write" 
    capabilities = ["submit-job", "read-logs", "read-fs"]
}

// namespace "*" { 
//     policy = "read" 
//     capabilities = ["submit-job", "read-logs", "read-fs"]
// }