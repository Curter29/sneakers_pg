# старый подход решения
# Подождать какое то время, чтобы не плодить битые воркеры пока переключается haproxy
# sleep 2
# Убиваем этот процесс, мастер процесс породит новый уже с нормальным соединением
# Process.kill('TERM', Process.pid)

module Sneakers
  module Worker
    PG_EXCEPTION = [PG::ConnectionBad, PG::UnableToSend]

    def do_work(delivery_info, metadata, msg, handler)
      @__initial_reconnect ||= ActiveRecord::Base.connection.reconnect! && :done

      # https://github.com/jondot/sneakers/blob/master/lib/sneakers/worker.rb#L46
      worker_trace "Working off: #{msg.inspect}"

      # пул потоков - нужно ловить ex внутри потока!
      # тк все ex уже ловятся внутри process_work, мы делаем re-raise в worker_error
      @pool.post do
        begin
          process_work(delivery_info, metadata, msg, handler)
        rescue *PG_EXCEPTION => exception
          sleep 2
          logger.error(exception)

          begin
            ActiveRecord::Base.connection.reconnect!
            Sneakers::CONFIG[:hooks][:after_pg_broken].call if Sneakers::CONFIG[:hooks][:after_pg_broken]
          rescue => reconnect_exception
            sleep 2
            logger.error(reconnect_exception)

            retry
          end

          retry
        end
      end
    end

    def worker_error(exception, context_hash = {})
      case exception
      when *PG_EXCEPTION
        raise exception
      else
        super(exception, context_hash)
      end
    end
  end
end
