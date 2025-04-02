# Procedimientos:

```sql
CREATE OR REPLACE PROCEDURE consultarlibro(

    vdni IN VARCHAR2,
    vnombre_l OUT VARCHAR2,
    vprecio OUT NUMBER
    
) IS
BEGIN

    SELECT nombre_l, precio INTO vnombre_l, vprecio
    FROM libro 
    WHERE dni = vdni;
    
EXCEPTION

    WHEN no_data_found THEN
        dbms_output.put_line('la consulta no a devuelto ninguna fila');
    WHEN too_many_rows THEN
        dbms_output.put_line('la consulta devuelve demasiadas filas');

END;
```

llamador:
```sql
declare
    vDNI libro.dni % type;
    vNombre_l libro.nombre_l % type;
    vPrecio libro.precio %  type;
begin

    vdni := '&dni';
    consultarlibro(vDNI, vNombre_l, vprecio);
    dbms_output.put_line(vNombre_l);
    dbms_output.put_line(vprecio);
end;
```

# Funciones:
```sql
CREATE OR REPLACE FUNCTION consultarPrecio (vPrecio NUMBER) return number is
    vNumero Number := 0;
begin

    select count(*) into vNumero
    from libro
    where precio > vPrecio;
    
    return vNumero;
    
end;
```

llamador:
```sql
declare
    vNumeroFuncion Number := 0;
    vPrecio libro.precio % type;
begin
    vPrecio := &precio;
    vNumeroFuncion := consultarPrecio(vPrecio);
    dbms_output.put_line('Hay ' || vNumeroFuncion || ' libros con un precio superior a ' || vPrecio);
end;
```