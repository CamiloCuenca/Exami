package edu.uniquindio.exami.dto;

public class NotaResponseDTO {
    private Double nota;
    private int codigoResultado;
    private String mensaje;

    public NotaResponseDTO(Double nota, int codigoResultado, String mensaje) {
        this.nota = nota;
        this.codigoResultado = codigoResultado;
        this.mensaje = mensaje;
    }

    // getters y setters
    public Double getNota() { return nota; }
    public void setNota(Double nota) { this.nota = nota; }
    public int getCodigoResultado() { return codigoResultado; }
    public void setCodigoResultado(int codigoResultado) { this.codigoResultado = codigoResultado; }
    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }
}

