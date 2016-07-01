module Queryable
  def where(*args)
    select do |game|
      args.all? do |arg|
        arg.all? do |k,v|
          k = k.to_s.pluralize if game.respond_to?(k.to_s.pluralize)
          game.send(k.to_sym) == v || game.send(k.to_sym).include?(v)
        end
      end
    end
  end

  def find_by(*args)
    where(*args).first
  end
end
