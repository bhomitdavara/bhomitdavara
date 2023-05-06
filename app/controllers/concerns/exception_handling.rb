module ExceptionHandling
  extend ActiveSupport::Concern

  included do
    # Rescue from missing parameter error
    rescue_from ActionController::ParameterMissing do |exception|
      render json: {
        status: 'Missing Parameter(s)',
        code: 422,
        errors: [],
        message: "One or more parameters are missing. #{exception}"
      }, status: 422
    end

    rescue_from ActionController::UnpermittedParameters do |exception|
      render json: {
        status: 'Unpermitted Parameter(s)',
        code: 422,
        errors: [],
        message: "One or more parameters are not permitted: #{exception}"
      }, status: 422
    end

    if Rails.env.production?
      rescue_from ArgumentError, with: :render_500
      rescue_from NoMethodError, with: :render_500
      rescue_from ::AbstractController::ActionNotFound, with: :render_500
      rescue_from ActiveRecord::RecordNotFound, with: :render_500
      rescue_from ActionView::Template::Error, with: :render_500
      rescue_from Pagy::OverflowError, with: :render_404
    end
  end

  protected

  def render_json(msg, data = {}, msg_type ='success')
    render json: { status: 'OK', message: [msg], data: data, status_code: 200, messageType: msg_type }, status: 200
  end

  def render_422(msg)
    render json: { status: 'Unprocessable Entity', message: [msg].flatten, data: {}, status_code: 422,
                   messageType: 'error' }, status: 422
  end

  def render_203(msg)
    render json: { status: 'Non-Authoritative Information', message: [msg].flatten, data: {}, status_code: 203,
                   messageType: 'error' }, status: 203
  end

  def render_400(msg)
    render json: { status: 'Bad Request', message: [msg], data: {}, status_code: 400,
                   messageType: 'error' }, status: 400
  end

  def render_404(msg = t('exception.404.message'))
    render json: { status: 'Not Found', message: [msg], data: {}, status_code: 404,
                   messageType: 'error' }, status: 404
  end

  def render_500
    render json: { status: 'Internal Server Error', message: ['Something went wrong, please try after some time'],
                   data: {}, status_code: 500, messageType: 'error' }, status: 500
  end

  def render_401(message = t('exception.401.message'))
    render json: { status: 'Unauthorized', message: [message], data: {}, status_code: 401,
                   messageType: 'error' }, status: 401
  end
end
