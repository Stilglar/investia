<?php
    session_start();
    
    $_SESSION['user'] = $_GET['usuario'];
    $_SESSION['userFull'] = $_GET['usuarioComp'];
    $_SESSION['fullName'] = $_GET['nomComp'];
    $_SESSION['isAdmin'] = $_GET['isAdmin'];

    //print('<pre>' . print_r($_SESSION,true) . '</pre>');

    header('location:principal.php');
    
?>