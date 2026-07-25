@tool
extends TextureRect

enum Formato { PNG, JPG, WEBP }

@export_global_dir var pasta_saida: String = "res://exports"
@export var nome_arquivo: String = "textura_exportada"
@export var formato: Formato = Formato.PNG
@export var aplicar_material: bool = true
@export var qualidade_jpg: float = 0.9
@export var qualidade_webp: float = 0.9

@export_tool_button("Salvar", "Add") var salvar: Callable = exportar_textura

func exportar_textura() -> void:
	if texture == null:
		push_error("Nenhuma textura encontrada.")
		return

	# Cria viewport temporário
	var viewport: SubViewport = SubViewport.new()

	viewport.disable_3d = true
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

	add_child(viewport)

	# Descobre tamanho da textura
	var tamanho: Vector2i = texture.get_size()

	if tamanho.x <= 0 or tamanho.y <= 0:
		push_error("Tamanho inválido da textura.")
		viewport.queue_free()
		return

	viewport.size = tamanho

	# Cria TextureRect temporário
	var temp_rect: TextureRect = TextureRect.new()

	temp_rect.texture = texture
	temp_rect.size = tamanho
	temp_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	temp_rect.stretch_mode = TextureRect.STRETCH_SCALE

	# Copia material opcionalmente
	if aplicar_material and material:
		temp_rect.material = material.duplicate()

	viewport.add_child(temp_rect)

	# Espera renderizar
	await RenderingServer.frame_post_draw

	# Captura imagem
	var imagem: Image = viewport.get_texture().get_image()

	if imagem == null:
		push_error("Falha ao capturar imagem.")
		viewport.queue_free()
		return

	# Garante diretório
	if not DirAccess.dir_exists_absolute(pasta_saida):
		DirAccess.make_dir_recursive_absolute(pasta_saida)

	# Define o nome do arquivo
	var nome: String = nome_arquivo.strip_edges()

	if nome.is_empty():
		var data: Dictionary = Time.get_datetime_dict_from_system()

		nome = "export_%04d-%02d-%02d_%02d-%02d-%02d" % [
			data.year,
			data.month,
			data.day,
			data.hour,
			data.minute,
			data.second
		]

	var caminho: String = ""

	match formato:
		Formato.PNG:
			caminho = pasta_saida.path_join(nome + ".png")
			imagem.save_png(caminho)

		Formato.JPG:
			caminho = pasta_saida.path_join(nome + ".jpg")
			imagem.save_jpg(caminho, qualidade_jpg)

		Formato.WEBP:
			caminho = pasta_saida.path_join(nome + ".webp")
			imagem.save_webp(caminho, false, qualidade_webp)

	print("Textura salva em: ", caminho)

	viewport.queue_free()
