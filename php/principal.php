<?php
    session_start();
    include '../funciones/php/connection.php';

    //print('<pre>' . print_r($_SESSION,true) . '</pre>');

    $user = $_SESSION['user'];
    $userFull = $_SESSION['userFull'];
    $fullName = $_SESSION['fullName'];
    $isAdmin = $_SESSION['isAdmin'];

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>Principal</title>
    <link rel="stylesheet" href="../css/principal.css" />
    <script src="../funciones/js/jquery.min.js"></script>
    <script src="../funciones/js/principal.js"></script>
</head>

<body>
    <div id="divCabecera">
        <img src="../img/investia.png" alt="Logotipo Investia">
        <div id="divUsuario">
            <p>Bienvenid@ <?php echo $fullName ?></p>
            <a href="cerrarSesion.php">Cerrar Sesion</a>
        </div>
    </div>
    <div id="divGeneral">
        <div id="divLateral">
            <ul id="listaMenu">
                <?php
                    if($isAdmin == 0)
                    {
                        echo '<li onclick="fCargaCompras()" >Compras</li>';
                        echo '<li onclick="fCargaViajes()" >Viajes</li>';
                        echo '<li onclick="fCargaVacaciones()" >Vacaciones</li>';
                        echo '<li onclick="fCargaAnticipos()" >Anticipos</li>';
                        echo '<li onclick="fCargaReservas()" >Reservas</li>';
                    }
                    else if($isAdmin == 2)
                    {
                        echo '<li onclick="fCargaCompras()" >Compras</li>';
                        echo '<li onclick="fCargaViajes()" >Viajes</li>';
                        echo '<li onclick="fCargaVacaciones()" >Vacaciones</li>';
                        echo '<li onclick="fCargaAnticipos()" >Anticipos</li>';
                        echo '<li onclick="fCargaReservas()" >Reservas</li>';
                        echo '<li onclick="fCargaSolicitudes()" >Solicitudes</li>';
                    }

                ?>
            </ul>
        </div>
        <div id="divContenido">
            <div id="divSubContenido1"></div>
            <div id="divSubContenido2"></div>
        </div>
    </div>
    <div id="divPie">

    </div>
</body>

</html>