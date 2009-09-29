namespace :tweets do
	desc "calculates tweet's shaky rating"
	task(:calc_shakiness => :environment) do
		Tweet.calc_shakers
	end
end
