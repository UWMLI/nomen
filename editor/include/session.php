<?php

// From http://www.wikihow.com/Create-a-Secure-Login-Script-in-PHP-and-MySQL

require_once 'config.php';

function sec_session_start() {
    $session_name = 'sec_session_id';   // Set a custom session name
    $secure = SECURE;
    // This stops JavaScript being able to access the session id.
    $httponly = true;
    // Forces sessions to only use cookies.
    if (ini_set('session.use_only_cookies', 1) === FALSE) {
        echo 'Error: could not initiate a safe session.';
        exit();
    }
    // Gets current cookies params.
    $cookieParams = session_get_cookie_params();
    session_set_cookie_params($cookieParams["lifetime"],
        $cookieParams["path"],
        $cookieParams["domain"],
        $secure,
        $httponly);
    // Sets the session name to the one set above.
    session_name($session_name);
    session_start();            // Start the PHP session
    session_regenerate_id();    // regenerated the session, delete the old one.
}

function login($email, $password, $mysqli) {
    // Using prepared statements means that SQL injection is not possible.
    if ($stmt = $mysqli->prepare("SELECT id, password, salt
        FROM users
        WHERE email = ?
        LIMIT 1")) {
        $stmt->bind_param('s', $email);  // Bind "$email" to parameter.
        $stmt->execute();    // Execute the prepared query.
        $stmt->store_result();

        // get variables from result.
        $stmt->bind_result($user_id, $db_password, $salt);
        $stmt->fetch();

        // hash the password with the unique salt.
        $password = hash('sha512', $password . $salt);
        if ($stmt->num_rows == 1) {
            // Check if the password in the database matches
            // the password the user submitted.
            if ($db_password == $password) {
                // Password is correct!
                // Get the user-agent string of the user.
                $user_browser = $_SERVER['HTTP_USER_AGENT'];
                // XSS protection as we might print this value
                $user_id = preg_replace("/[^0-9]+/", "", $user_id);
                $_SESSION['user_id'] = $user_id;
                // XSS protection as we might print this value
                $email = filter_var($email, FILTER_SANITIZE_EMAIL);
                $_SESSION['email'] = $email;
                $_SESSION['login_string'] = hash('sha512',
                          $password . $user_browser);
                // Login successful.
                return true;
            } else {
                // Password is not correct
                return false;
            }
        } else {
            // No user exists.
            return false;
        }
    }
    // Error preparing statement?
    return false;
}

function login_check($mysqli) {
    // Check if all session variables are set
    if (isset($_SESSION['user_id'],
                        $_SESSION['email'],
                        $_SESSION['login_string'])) {

        $user_id = $_SESSION['user_id'];
        $login_string = $_SESSION['login_string'];
        $email = $_SESSION['email'];

        // Get the user-agent string of the user.
        $user_browser = $_SERVER['HTTP_USER_AGENT'];

        if ($stmt = $mysqli->prepare("SELECT password
                                      FROM users
                                      WHERE id = ? LIMIT 1")) {
            // Bind "$user_id" to parameter.
            $stmt->bind_param('i', $user_id);
            $stmt->execute();   // Execute the prepared query.
            $stmt->store_result();

            if ($stmt->num_rows == 1) {
                // If the user exists get variables from result.
                $stmt->bind_result($password);
                $stmt->fetch();
                $login_check = hash('sha512', $password . $user_browser);

                if ($login_check == $login_string) {
                    // Logged In!!!!
                    return true;
                } else {
                    // Not logged in
                    return false;
                }
            } else {
                // Not logged in
                return false;
            }
        } else {
            // Not logged in
            return false;
        }
    } else {
        // Not logged in
        return false;
    }
}

function logout() {
    // Unset all session values
    $_SESSION = array();

    // get session parameters
    $params = session_get_cookie_params();

    // Delete the actual cookie.
    setcookie(session_name(),
            '', time() - 42000,
            $params["path"],
            $params["domain"],
            $params["secure"],
            $params["httponly"]);

    // Destroy session
    session_destroy();
}

function create_account($email, $password, $mysqli) {
    $random_salt = hash('sha512', uniqid(mt_rand(1, mt_getrandmax()), true));
    $password = hash('sha512', $password . $random_salt);
    if ($insert_stmt = $mysqli->prepare("INSERT INTO users (email, password, salt) VALUES (?, ?, ?)")) {
        $insert_stmt->bind_param('sss', $email, $password, $random_salt);
        if ($insert_stmt->execute()) {
            return true;
        }
        else {
            // Couldn't INSERT, probably email already exists
            return false;
        }
    }
    // Failed to prepare statement
    return false;
}
