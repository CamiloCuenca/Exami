public interface UsuarioRepository {
    // Métodos para consultas de lectura (NO para modificaciones)
    List<Usuario> findByIdTipoUsuario(TipoUsuario tipoUsuario);

    Optional<Usuario> findByEmail(String email);
    // Otros métodos de consulta...

}
