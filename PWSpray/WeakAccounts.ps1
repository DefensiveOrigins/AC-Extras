# Import the Active Directory module
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# Define possible seasons and years
$seasons = @("Winter", "Spring", "Summer", "Autumn")
$years = @(2024..2030)

# Generate a list of random first and last names
$firstNames = @("Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Hank", "Ivy", "Jack", "Karen", "Leo", "Mia", "Nathan", "Olivia", "Paul", "Quinn", "Rachel", "Steve", "Tina", "Uma", "Victor", "Wendy", "Xavier", "Yvonne", "Zane")
$lastNames = @("Anderson", "Brown", "Clark", "Davis", "Evans", "Franklin", "Garcia", "Harris", "Irwin", "Jackson", "King", "Lewis", "Miller", "Nelson", "Owens", "Parker", "Quincy", "Reynolds", "Smith", "Taylor", "Underwood", "Vasquez", "Wilson", "Xu", "Young", "Zimmerman")

# Shuffle the names to ensure randomness
$random = New-Object System.Random

# Function to generate a random name
function Get-RandomName {
    param ($nameList)
    return $nameList[$random.Next(0, $nameList.Count)]
}

# Store created usernames to prevent duplicates
$usernames = @{}
$successCount = 0  # Counter for successful account creations

# Generate user accounts ensuring at least one for each password
foreach ($season in $seasons) {
    foreach ($year in $years) {
        do {
            # Generate a random first and last name
            $firstName = Get-RandomName -nameList $firstNames
            $lastName = Get-RandomName -nameList $lastNames

            # Create a username based on first initial and last name
            $username = ($firstName.Substring(0,1) + $lastName).ToLower()

            # Ensure uniqueness
        } while ($usernames.ContainsKey($username))

        # Store username
        $usernames[$username] = $true

        # Generate password
        $password = "$season$year!"

        # Try to create the AD user and handle any errors silently
        try {
            New-ADUser -Name "$firstName $lastName" `
                       -GivenName $firstName `
                       -Surname $lastName `
                       -SamAccountName $username `
                       -UserPrincipalName "$username@doazlab.com" `
                       -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
                       -Enabled $true `
                       -PassThru -ErrorAction Stop | Out-Null
            $successCount++  # Increment success counter if no error
        } catch {
            # Suppress errors without halting the script
            continue
        }
    }
}

# Output total number of accounts successfully created
Write-Output "Total accounts successfully created: $successCount"
