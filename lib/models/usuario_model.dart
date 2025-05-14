import 'package:intl/intl.dart';

class Usuario {
  final String? claveAcceso;
  final String? updated;
  final int? idUsuario;
  final int? idPerfil;
  final String? usuario;
  final String? noEmpleado;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String? nombres;
  final String? nombreCompleto;
  final DateTime? fechaAlta;
  final DateTime? ultimoAcceso;
  final String? correo;
  final String? correoPersonal;
  final int? idOficina;
  final int? idPuesto;
  final String? nombreOficina;
  final String? idClienteOficina;
  final String? idClienteSucursal;
  final String? nombreZona;
  final int? idZona;
  final String? nombrePuesto;
  final String? claveEmpresaPuesto;
  final String? nombreDepartamento;
  final String? claveEmpresaDepartamento;
  final int? idDepartamento;
  final String? nombreArea;
  final String? claveEmpresaArea;
  final int? idArea;
  final String? nombreEmpresa;
  final int? idClienteEmpresa;
  final int? idUsuarioMetricas;
  final String? sobreMi;
  final int? aprendizajeVisual;
  final int? aprendizajeAuditivo;
  final int? aprendizajeCinestesico;
  final int? idSucursal;
  final String? sucursalNombre;

  Usuario({
    this.apellidoMaterno,
    this.apellidoPaterno,
    this.aprendizajeAuditivo,
    this.aprendizajeCinestesico,
    this.aprendizajeVisual,
    this.claveAcceso,
    this.claveEmpresaArea,
    this.claveEmpresaDepartamento,
    this.claveEmpresaPuesto,
    this.correo,
    this.correoPersonal,
    this.fechaAlta,
    this.idArea,
    this.idClienteEmpresa,
    this.idClienteOficina,
    this.idClienteSucursal,
    this.idDepartamento,
    this.idOficina,
    this.idPerfil,
    this.idPuesto,
    this.idSucursal,
    this.idUsuario,
    this.idUsuarioMetricas,
    this.idZona,
    this.noEmpleado,
    this.nombreArea,
    this.nombreCompleto,
    this.nombreDepartamento,
    this.nombreEmpresa,
    this.nombreOficina,
    this.nombrePuesto,
    this.nombreZona,
    this.nombres,
    this.sobreMi,
    this.sucursalNombre,
    this.ultimoAcceso,
    this.updated,
    this.usuario,
  });

  static DateTime parseDate(String? date) {
    try {
      if (date == null || date.trim().isEmpty) return DateTime(2000);
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (_) {
      return DateTime(2000);
    }
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      apellidoMaterno: json['apellido_materno'] ?? '',
      apellidoPaterno: json['apellido_paterno'] ?? '',
      aprendizajeAuditivo: json['aprendizaje_auditivo'] ?? 0,
      aprendizajeCinestesico: json['aprendizaje_cinestesico'] ?? 0,
      aprendizajeVisual: json['aprendizaje_visual'] ?? 0,
      claveAcceso: json['clave_acceso'] ?? '',
      claveEmpresaArea: json['clave_empresa_area'] ?? '',
      claveEmpresaDepartamento: json['clave_empresa_departamento'] ?? '',
      claveEmpresaPuesto: json['clave_empresa_puesto'] ?? '',
      correo: json['correo'] ?? '',
      correoPersonal: json['correo_personal'] ?? '',
      fechaAlta: parseDate(json['fecha_alta']),
      idArea: json['id_area'] ?? 0,
      idClienteEmpresa: json['id_cliente_empresa'] ?? 0,
      idClienteOficina: json['id_cliente_oficina'] ?? '',
      idClienteSucursal: json['id_cliente_sucursal'] ?? '',
      idDepartamento: json['id_departamento'] ?? 0,
      idOficina: json['id_oficina_fk'] ?? 0,
      idPerfil: json['id_perfil_fk'] ?? 0,
      idPuesto: json['id_puesto_fk'] ?? 0,
      idSucursal: json['id_sucursal'] ?? 0,
      idUsuario: json['id_usuario'] ?? 0,
      idUsuarioMetricas: json['id_usuario_metricas'] ?? 0,
      idZona: json['id_zona'] ?? 0,
      noEmpleado: json['no_empleado'] ?? '',
      nombreArea: json['nombre_area'] ?? '',
      nombreCompleto: json['nombre_completo'] ?? '',
      nombreDepartamento: json['nombre_departamento'] ?? '',
      nombreEmpresa: json['nombre_empresa'] ?? '',
      nombreOficina: json['nombre_oficina'] ?? '',
      nombrePuesto: json['nombre_puesto'] ?? '',
      nombreZona: json['nombre_zona'] ?? '',
      nombres: json['nombres'] ?? '',
      sobreMi: json['sobre_mi'] ?? '',
      sucursalNombre: json['sucursal_nombre'] ?? '',
      ultimoAcceso: parseDate(json['ultimo_acceso']),
      updated: json['updated'] ?? '',
      usuario: json['usuario'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final format = DateFormat('dd/MM/yyyy');
    return {
      'apellido_materno': apellidoMaterno,
      'apellido_paterno': apellidoPaterno,
      'aprendizaje_auditivo': aprendizajeAuditivo,
      'aprendizaje_cinestesico': aprendizajeCinestesico,
      'aprendizaje_visual': aprendizajeVisual,
      'clave_acceso': claveAcceso,
      'clave_empresa_area': claveEmpresaArea,
      'clave_empresa_departamento': claveEmpresaDepartamento,
      'clave_empresa_puesto': claveEmpresaPuesto,
      'correo': correo,
      'correo_personal': correoPersonal,
      'fecha_alta': format.format(fechaAlta!),
      'id_area': idArea,
      'id_cliente_empresa': idClienteEmpresa,
      'id_cliente_oficina': idClienteOficina,
      'id_cliente_sucursal': idClienteSucursal,
      'id_departamento': idDepartamento,
      'id_oficina_fk': idOficina,
      'id_perfil_fk': idPerfil,
      'id_puesto_fk': idPuesto,
      'id_sucursal': idSucursal,
      'id_usuario': idUsuario,
      'id_usuario_metricas': idUsuarioMetricas,
      'id_zona': idZona,
      'no_empleado': noEmpleado,
      'nombre_area': nombreArea,
      'nombre_completo': nombreCompleto,
      'nombre_departamento': nombreDepartamento,
      'nombre_empresa': nombreEmpresa,
      'nombre_oficina': nombreOficina,
      'nombre_puesto': nombrePuesto,
      'nombre_zona': nombreZona,
      'nombres': nombres,
      'sobre_mi': sobreMi,
      'sucursal_nombre': sucursalNombre,
      'ultimo_acceso': format.format(ultimoAcceso!),
      'updated': updated,
      'usuario': usuario,
    };
  }
}
