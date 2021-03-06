function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

% compute h_theta = a3
a1 = [ones(m, 1) X]; %5000x401
a2 = sigmoid(Theta1 * a1'); %25x5000
a2 = [ones(1, m); a2]; %26x5000
a3 = sigmoid(a2' * Theta2'); %5000x10
h_theta = a3;

% prefer to use K instead of num_labels for clarity
K = num_labels;

% make yk a matrix of 5000x10 which is derived from y (a matrix of size 5000 1), each row in yk has a value of 1 on the row indicated by each entry in y, and all 0s elsewhere
yk= eye(K)(y, :);

% compute the cost function for each input value 1 .. 5000
% cost is a matrix of size 5000 10
cost = ( -yk.* log(h_theta) ) -(1-yk) .* log(1-h_theta); 

% unroll cost using cost(:), then sum all the elements
J = (1/m) * sum(cost(:));

%Implement regularization with the cost function 

%do not regularize bias (the first column of the matrix
Theta1_reg = Theta1(:, 2:end);
Theta2_reg = Theta2(:, 2:end);

% use the sumsq function which is clearer and faster than .^
reg_term = (lambda/(2*m)) * (sumsq(Theta1_reg(:)) + sumsq(Theta2_reg(:)));

% the final regularized cost value
J = J + reg_term;


%%%backpropagation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Delta_1 = 0;
Delta_2 = 0;

for t = 1:m

	a1 = X(t, :)';				% take each row from X
	a1 = [1; a1];				% add +1 bias unit
	z2 = Theta1 * a1;
	a2 = sigmoid(z2);
	a2 = [1; a2];				% add +1 bias unit
	z3 = Theta2 * a2;
	a3 = sigmoid(z3);	
	
	% compute error for l=3
	actual = y(t, :);
	y_k = zeros(num_labels, 1);
	y_k(actual) = 1;
	delta_3 = a3 - y_k;
	Delta_2 = Delta_2 + (delta_3 * a2');
	
	% compute error for l=2
	delta_2 = (Theta2(:, 2:end)' * delta_3) .* sigmoidGradient(z2);
	Delta_1 = Delta_1 + (delta_2 * a1');
	
end

% the original non-regularized calculation for gradients
Theta1_grad = (1/m) * Delta_1;
Theta2_grad = (1/m) * Delta_2;

% Implement regularization with the gradients.
% compute regularization terms for Theta1_grad and Theta2_grad
reg_term1 = (lambda/m) * Theta1(:, 2:end);
Theta1_grad(:, 2:end) = Theta1_grad(:, 2:end) + reg_term1;
		
reg_term2 = (lambda/m) * Theta2(:, 2:end);
Theta2_grad(:, 2:end) = Theta2_grad(:, 2:end) + reg_term2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%













% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
