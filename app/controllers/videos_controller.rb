class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit, :update, :destroy]

  def index
    @videos = Video.all
  end

  def show
  end

  def new
    @video = Video.new
  end

  def edit
  end

  def create
    @video = Video.new(video_params)

    respond_to do |format|
      if @video.save
        if uploaded_video_tempfile
          save_uploaded_video(@video, uploaded_video_tempfile)
        end
        format.html { redirect_to @video, notice: I18n.t("video.actions.created") }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to @video, notice: I18n.t("video.actions.updated") }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @video.destroy
    respond_to do |format|
      format.html { redirect_to videos_url, notice: I18n.t("video.actions.destroyed") }
    end
  end

  private
    def set_video
      @video = Video.find(params[:id])
    end

    def video_params
      params.require(:video).permit(:title, :watermark)
    end

    def uploaded_video_tempfile
      params[:video][:file]
    end

    def save_uploaded_video(video, tempfile)
      filename = sanitize_filename(tempfile.original_filename)
      filepath = video.assets_directory.join(filename).to_s
      FileUtils.mkdir_p(File.dirname(filepath))
      FileUtils.cp(tempfile.path, filepath)
      video.original_filepath = filepath
      video.save
    end

    def sanitize_filename(filename)
      File.basename(filename.to_s).gsub(/^.*(\\|\/)/, '').gsub(/[^0-9A-ZА-Я.\-]/i, '_')
    end
end
