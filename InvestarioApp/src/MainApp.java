import javafx.application.Application;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.BorderPane;
import javafx.stage.Stage;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;

import java.sql.*;

public class MainApp extends Application {

    // Campos de entrada del formulario
    @FXML private TextField nombreField;
    @FXML private TextField descripcionField;
    @FXML private TextField cantidadField;
    @FXML private TextField precioField;

    // Tabla y columnas
    @FXML private TableView<Producto> tableView;
    @FXML private TableColumn<Producto, Integer> idColumn;
    @FXML private TableColumn<Producto, String> nombreColumn;
    @FXML private TableColumn<Producto, String> descripcionColumn;
    @FXML private TableColumn<Producto, Integer> cantidadColumn;
    @FXML private TableColumn<Producto, Double> precioColumn;

    // Lista de productos que se mostrará en la tabla
    private ObservableList<Producto> data = FXCollections.observableArrayList();

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage stage) throws Exception {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("inventario_view.fxml"));
        loader.setController(this);
        BorderPane root = loader.load();

        Scene scene = new Scene(root, 800, 500);
        stage.setTitle("Gestión de Inventarios");
        stage.setScene(scene);
        stage.show();

        initializeTable();
        loadData();
    }

    // Configura cómo se muestran los datos en las columnas del TableView
    public void initializeTable() {
        idColumn.setCellValueFactory(cellData -> cellData.getValue().idProperty().asObject());
        nombreColumn.setCellValueFactory(cellData -> cellData.getValue().nombreProperty());
        descripcionColumn.setCellValueFactory(cellData -> cellData.getValue().descripcionProperty());
        cantidadColumn.setCellValueFactory(cellData -> cellData.getValue().cantidadProperty().asObject());
        precioColumn.setCellValueFactory(cellData -> cellData.getValue().precioProperty().asObject());

        tableView.setItems(data);
    }

    // Carga los datos desde la base de datos y los añade a la tabla
    public void loadData() {
        data.clear();
        try (Connection conn = DriverManager.getConnection("jdbc:sqlite:inventario.db");
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM productos")) {
            while (rs.next()) {
                data.add(new Producto(
                        rs.getInt("id"),
                        rs.getString("nombre"),
                        rs.getString("descripcion"),
                        rs.getInt("cantidad"),
                        rs.getDouble("precio")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Inserta un nuevo producto en la base de datos
    @FXML
    private void handleInsert() {
        try (Connection conn = DriverManager.getConnection("jdbc:sqlite:inventario.db");
             PreparedStatement stmt = conn.prepareStatement("INSERT INTO productos (nombre, descripcion, cantidad, precio) VALUES (?, ?, ?, ?)")) {
            stmt.setString(1, nombreField.getText());
            stmt.setString(2, descripcionField.getText());
            stmt.setInt(3, Integer.parseInt(cantidadField.getText()));
            stmt.setDouble(4, Double.parseDouble(precioField.getText()));
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        loadData();
        clearFields();
    }

    // Actualiza el producto seleccionado
    @FXML
    private void handleUpdate() {
        Producto selected = tableView.getSelectionModel().getSelectedItem();
        if (selected == null) return;

        try (Connection conn = DriverManager.getConnection("jdbc:sqlite:inventario.db");
             PreparedStatement stmt = conn.prepareStatement("UPDATE productos SET nombre = ?, descripcion = ?, cantidad = ?, precio = ? WHERE id = ?")) {
            stmt.setString(1, nombreField.getText());
            stmt.setString(2, descripcionField.getText());
            stmt.setInt(3, Integer.parseInt(cantidadField.getText()));
            stmt.setDouble(4, Double.parseDouble(precioField.getText()));
            stmt.setInt(5, selected.getId());
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        loadData();
    }

    // Elimina el producto seleccionado
    @FXML
    private void handleDelete() {
        Producto selected = tableView.getSelectionModel().getSelectedItem();
        if (selected == null) return;

        try (Connection conn = DriverManager.getConnection("jdbc:sqlite:inventario.db");
             PreparedStatement stmt = conn.prepareStatement("DELETE FROM productos WHERE id = ?")) {
            stmt.setInt(1, selected.getId());
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        loadData();
    }

    // Limpia los campos de entrada
    private void clearFields() {
        nombreField.clear();
        descripcionField.clear();
        cantidadField.clear();
        precioField.clear();
    }
}
