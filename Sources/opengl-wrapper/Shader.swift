import SGLOpenGL

public class GLShader {
	public enum ShaderType: GLenum {
		case vertex = 0x8B31
		case tessControl = 0x8E88
		case tessEvaluation = 0x8E87
		case geometry = 0x8DD9
		case fragment = 0x8B30
		case compute = 0x91B9
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
