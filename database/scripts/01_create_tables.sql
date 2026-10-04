-- =============================================================
-- PROYECTO INTEGRADOR: SISTEMA DE VENTAS
-- Autor: Moises Rimachi Cusi
-- Curso: Proyecto Integrador de Sistemas
-- Gestor: MySQL mediante XAMPP/phpMyAdmin
-- Sesion: N.° 11
-- Descripcion: Creacion fisica de la base de datos y sus tablas
-- =============================================================

-- 1. Creacion de la base de datos
CREATE DATABASE IF NOT EXISTS bd_sistema_ventas
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE bd_sistema_ventas;

-- =============================================================
-- 2. Tablas independientes
-- =============================================================

-- Tabla de categorias de productos
CREATE TABLE categorias (
    id_categoria INT UNSIGNED AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    descripcion VARCHAR(255),
    estado BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_categorias PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categorias_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

-- Tabla de clientes
CREATE TABLE clientes (
    id_cliente INT UNSIGNED AUTO_INCREMENT,
    dni CHAR(8) NOT NULL,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    correo VARCHAR(120),
    direccion VARCHAR(180),
    estado BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_clientes PRIMARY KEY (id_cliente),
    CONSTRAINT uq_clientes_dni UNIQUE (dni),
    CONSTRAINT uq_clientes_correo UNIQUE (correo),
    CONSTRAINT ck_clientes_dni CHECK (CHAR_LENGTH(dni) = 8)
) ENGINE = InnoDB;

-- Tabla de proveedores
CREATE TABLE proveedores (
    id_proveedor INT UNSIGNED AUTO_INCREMENT,
    ruc CHAR(11) NOT NULL,
    razon_social VARCHAR(150) NOT NULL,
    telefono VARCHAR(15),
    correo VARCHAR(120),
    direccion VARCHAR(180),
    estado BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_proveedores PRIMARY KEY (id_proveedor),
    CONSTRAINT uq_proveedores_ruc UNIQUE (ruc),
    CONSTRAINT uq_proveedores_correo UNIQUE (correo),
    CONSTRAINT ck_proveedores_ruc CHECK (CHAR_LENGTH(ruc) = 11)
) ENGINE = InnoDB;

-- =============================================================
-- 3. Tablas relacionadas
-- =============================================================

-- Tabla de productos: pertenece a una categoria y a un proveedor
CREATE TABLE productos (
    id_producto INT UNSIGNED AUTO_INCREMENT,
    id_categoria INT UNSIGNED NOT NULL,
    id_proveedor INT UNSIGNED NOT NULL,
    codigo VARCHAR(30) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(255),
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    estado BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_productos PRIMARY KEY (id_producto),
    CONSTRAINT uq_productos_codigo UNIQUE (codigo),
    CONSTRAINT ck_productos_precio CHECK (precio > 0),
    CONSTRAINT ck_productos_stock CHECK (stock >= 0),

    CONSTRAINT fk_productos_categorias
        FOREIGN KEY (id_categoria)
        REFERENCES categorias (id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_productos_proveedores
        FOREIGN KEY (id_proveedor)
        REFERENCES proveedores (id_proveedor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

-- Tabla de ventas: registra la cabecera de cada venta
CREATE TABLE ventas (
    id_venta INT UNSIGNED AUTO_INCREMENT,
    id_cliente INT UNSIGNED NOT NULL,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo_comprobante ENUM('BOLETA', 'FACTURA') NOT NULL DEFAULT 'BOLETA',
    numero_comprobante VARCHAR(20) NOT NULL,
    estado ENUM('PENDIENTE', 'PAGADA', 'ANULADA') NOT NULL DEFAULT 'PENDIENTE',
    total DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT pk_ventas PRIMARY KEY (id_venta),
    CONSTRAINT uq_ventas_comprobante UNIQUE (tipo_comprobante, numero_comprobante),
    CONSTRAINT ck_ventas_total CHECK (total >= 0),

    CONSTRAINT fk_ventas_clientes
        FOREIGN KEY (id_cliente)
        REFERENCES clientes (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

-- Tabla de detalle: contiene los productos de cada venta
CREATE TABLE detalle_ventas (
    id_detalle INT UNSIGNED AUTO_INCREMENT,
    id_venta INT UNSIGNED NOT NULL,
    id_producto INT UNSIGNED NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) AS (cantidad * precio_unitario) STORED,

    CONSTRAINT pk_detalle_ventas PRIMARY KEY (id_detalle),
    CONSTRAINT uq_detalle_venta_producto UNIQUE (id_venta, id_producto),
    CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detalle_precio CHECK (precio_unitario > 0),

    CONSTRAINT fk_detalle_ventas
        FOREIGN KEY (id_venta)
        REFERENCES ventas (id_venta)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_detalle_productos
        FOREIGN KEY (id_producto)
        REFERENCES productos (id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

-- =============================================================
-- 4. Indices para optimizar consultas frecuentes
-- =============================================================

CREATE INDEX idx_productos_nombre ON productos (nombre);
CREATE INDEX idx_ventas_fecha ON ventas (fecha_venta);
CREATE INDEX idx_ventas_cliente ON ventas (id_cliente);
CREATE INDEX idx_detalle_producto ON detalle_ventas (id_producto);

-- =============================================================
-- 5. Consultas de verificacion
-- =============================================================

SHOW TABLES;

DESCRIBE categorias;
DESCRIBE clientes;
DESCRIBE proveedores;
DESCRIBE productos;
DESCRIBE ventas;
DESCRIBE detalle_ventas;

-- Verificacion de relaciones y restricciones
SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'bd_sistema_ventas'
ORDER BY TABLE_NAME, CONSTRAINT_TYPE;
