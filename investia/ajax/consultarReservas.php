<?php
	require("../funciones/php/connection.php");
	if(isset($_POST)){
		$equipo = $_POST['equipo'];
		$semana = $_POST['semana'];

		$string = "CALL pr_ConsultaReservas($equipo,$semana)";
		$resultado = mysqli_query($con,$string)
			or die("Ocurrio un error en la consulta SQL");
		if(mysqli_num_rows($resultado) != 0){
			$datos = array();
			while($fila = mysqli_fetch_assoc($resultado)){
				$datos[$fila['idPrestamo']] = $fila['usuario'] . '|' . $fila['fechaInicio'] . '|' . $fila['fechaFin'] . '|' . $fila['horaInicio'] . '|' . $fila['horaFin'];
			}
			echo(json_encode($datos));
			//print('<pre>' . print_r($datos,true) . '</pre>');
		}
		else{
			echo '{"vacio":"No hay reservas activas esta semana"}';
		}

		// Liberar resultados
		mysqli_free_result($resultado);
		// Cerrar la conexión
		mysqli_close($con);
	}
?>