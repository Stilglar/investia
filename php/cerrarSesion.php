<?php
    session_start();

    $_SESSION = array();

    session_destroy();

    echo "<h1>Se ha cerrado la sesion con éxito</h1>";
    echo "<h3>Redirigiendo...</h3>";

    header("refresh:2; url=../login.html");
?>