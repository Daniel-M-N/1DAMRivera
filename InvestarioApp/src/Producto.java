import javafx.beans.property.*;

public class Producto {
    private final IntegerProperty id;
    private final StringProperty nombre;
    private final StringProperty descripcion;
    private final IntegerProperty cantidad;
    private final DoubleProperty precio;

    public Producto(int id, String nombre, String descripcion, int cantidad, double precio) {
        this.id = new SimpleIntegerProperty(id);
        this.nombre = new SimpleStringProperty(nombre);
        this.descripcion = new SimpleStringProperty(descripcion);
        this.cantidad = new SimpleIntegerProperty(cantidad);
        this.precio = new SimpleDoubleProperty(precio);
    }

    public int getId() { return id.get(); }
    public void setId(int value) { id.set(value); }
    public IntegerProperty idProperty() { return id; }

    public String getNombre() { return nombre.get(); }
    public void setNombre(String value) { nombre.set(value); }
    public StringProperty nombreProperty() { return nombre; }

    public String getDescripcion() { return descripcion.get(); }
    public void setDescripcion(String value) { descripcion.set(value); }
    public StringProperty descripcionProperty() { return descripcion; }

    public int getCantidad() { return cantidad.get(); }
    public void setCantidad(int value) { cantidad.set(value); }
    public IntegerProperty cantidadProperty() { return cantidad; }

    public double getPrecio() { return precio.get(); }
    public void setPrecio(double value) { precio.set(value); }
    public DoubleProperty precioProperty() { return precio; }
}
