import SGLOpenGL

public class OGLShader {
	public enum ShaderType: GLenum {
		case vertex = 4
	}

	public internal(set) var id: GLuint

	public init() {
		self.id = glCreateProgram()
	}

	deinit {
		glDeleteProgram(self.id)
	}

	public func attachShader(type: ShaderType, source: String) throws {
		let shader: GLuint = glCreateShader(type.rawValue)

		source.withCString {
			var ptr = [$0]
			glShaderSource(shader, 1, &ptr, nil)
		}

		glCompileShader(shader)

		var success: GLint = 0
		var infoLog = [GLchar](repeating: 0, count: 512)
		glGetShaderiv(shader, GL_COMPILE_STATUS, &success)
		guard success == GL_TRUE else {
			glGetShaderInfoLog(shader, 512, nil, &infoLog)
			throw GLError.compileError(String(cString: infoLog))
		}

		glAttachShader(id, shader)
		glDeleteShader(shader)
	}

	public func linkProgram() throws {
		glLinkProgram(id)

		var success: GLint = 0
		var infoLog = [GLchar](repeating: 0, count: 512)
		glGetProgramiv(id, GL_LINK_STATUS, &success)
		guard success == GL_TRUE else {
			glGetProgramInfoLog(id, 512, nil, &infoLog)
			throw GLError.linkError(String(cString: infoLog))
		}
	}

	public func use() {
		glUseProgram(id)
	}
}
