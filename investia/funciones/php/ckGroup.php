<?php

function ckAdmin($user)
{
    if($user == 'administrador')
    {
        return true;
    }
    else
    {
        return false;
    }
}

function ckDomAdmin($memberOf)
{
    $admin = false;
    for($i=0;$i<$memberOf['count'];$i++)
    {
        if($memberOf[$i] == 'CN=Admins. del dominio,CN=Users,DC=investia,DC=es'){
            $admin = true;
            break;
        }
    }
    return $admin;
}

function ckDepDir($memberOf)
{
    $comp = false;
    for($i=0;$i<$memberOf['count'];$i++)
    {
        if($memberOf[$i] == 'CN=g_direccion,OU=direccion,OU=administracion,OU=intranet,DC=intranet,DC=investia,DC=es'){
            $comp = true;
            break;
        }
    }
    return $comp;
}
?>